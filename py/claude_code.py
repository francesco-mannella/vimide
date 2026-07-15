import json
import subprocess
import threading
import vim


class ClaudeCodeProvider():

    def __init__(self, command_type, raw_options, utils):
        self.utils = utils
        self.command_type = command_type
        self.options = raw_options
        # must run on the main thread: request() may run inside vim-ai's
        # background chat job thread, where the vim module is unsafe to call
        self.cwd = vim.eval('getcwd()')

    def request_image(self, prompt):
        raise self.utils.make_known_error('claudecode provider: image generation not supported')

    def request(self, messages):
        system_parts = []
        turns = []
        for message in messages:
            text = '\n'.join(c['text'] for c in message['content'] if c['type'] == 'text')
            if message['role'] == 'system':
                system_parts.append(text)
            elif message['role'] == 'assistant':
                turns.append(f"Assistant: {text}")
            else:
                turns.append(f"Human: {text}")
        prompt = '\n\n'.join(turns)

        cli_path = self.options.get('cli_path') or 'claude'
        argv = [
            cli_path, '-p', prompt,
            '--output-format', 'stream-json',
            '--include-partial-messages', '--verbose',
            '--tools', self.options.get('tools', ''),
        ]
        if system_parts:
            system_prompt = '\n\n'.join(system_parts)
            # edit/complete want raw output only; --append-system-prompt would
            # keep Claude Code's default agent persona, which encourages
            # explaining changes and defeats vim-ai's "no comments" instruction
            flag = '--append-system-prompt' if self.command_type == 'chat' else '--system-prompt'
            argv += [flag, system_prompt]
        if self.options.get('model'):
            argv += ['--model', self.options['model']]
        # never '--bare': that forces API-key billing instead of the subscription

        self.utils.print_debug("claudecode: [{}] argv: {}", self.command_type, argv)

        proc = subprocess.Popen(argv, cwd=self.cwd, stdout=subprocess.PIPE,
                                 stderr=subprocess.PIPE, text=True)

        # drain stderr concurrently: --verbose is chatty, and a full stderr
        # pipe would otherwise deadlock against the stdout read loop below
        stderr_lines = []
        stderr_thread = threading.Thread(target=lambda: stderr_lines.extend(proc.stderr), daemon=True)
        stderr_thread.start()

        result_error = None
        for line in proc.stdout:
            line = line.strip()
            if not line:
                continue
            event = json.loads(line)
            # errors surface as a stream-json event on stdout, not on stderr
            if event.get('type') == 'result' and event.get('is_error'):
                result_error = event.get('result')
                continue
            if event.get('type') != 'stream_event':
                continue
            inner = event.get('event', {})
            if inner.get('type') != 'content_block_delta':
                continue
            delta = inner.get('delta', {})
            if delta.get('type') == 'text_delta':
                yield {'type': 'assistant', 'content': delta.get('text', '')}

        proc.wait()
        stderr_thread.join()
        if proc.returncode != 0:
            message = result_error or ''.join(stderr_lines) or f'exited with code {proc.returncode}, no output'
            raise self.utils.make_known_error(message)
