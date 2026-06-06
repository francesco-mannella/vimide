import time
import torch
import torch.nn as nn


def make_moons(n=400, noise=0.2):
    n2 = n // 2
    t = torch.linspace(0, torch.pi, n2)
    X0 = torch.stack([torch.cos(t), torch.sin(t)], dim=1)
    X1 = torch.stack([1 - torch.cos(t), 0.5 - torch.sin(t)], dim=1)
    X = torch.cat([X0, X1]) + torch.randn(n, 2) * noise
    y = torch.cat([torch.zeros(n2), torch.ones(n2)]).unsqueeze(1)
    return X, y


class MLP(nn.Module):
    def __init__(self):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(2, 16), nn.ReLU(),
            nn.Linear(16, 16), nn.ReLU(),
            nn.Linear(16, 1), nn.Sigmoid(),
        )

    def forward(self, x):
        return self.net(x)


def train(model, X, y, epochs=200):
    opt = torch.optim.Adam(model.parameters(), lr=0.01)
    loss_fn = nn.BCELoss()
    for epoch in range(1, epochs + 1):
        pred = model(X)
        loss = loss_fn(pred, y)
        opt.zero_grad()
        loss.backward()
        opt.step()
        if epoch % 50 == 0:
            print(f"epoch {epoch:3d}  loss {loss.item():.4f}", flush=True)
            time.sleep(0.8)


if __name__ == "__main__":
    print("=== MLP  make_moons  2-16-16-1 ===")
    X, y = make_moons()
    model = MLP()
    train(model, X, y)
    with torch.no_grad():
        acc = ((model(X) > 0.5).float() == y).float().mean()
    print(f"Accuracy: {acc * 100:.2f}%")
