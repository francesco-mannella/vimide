import time

import torch
import torch.nn as nn


def make_moons(n=400, noise=0.2):
    n2 = n // 2
    t = torch.linspace(0, 3.14159, n2)
    x1 = torch.stack([torch.cos(t), torch.sin(t)], dim=1)
    x2 = torch.stack([1 - torch.cos(t), 1 - torch.sin(t) - 0.5], dim=1)
    X = torch.cat([x1, x2], dim=0)
    X = X + noise * torch.randn_like(X)
    y = torch.cat([torch.zeros(n2), torch.ones(n2)])
    return X, y


class MLP(nn.Module):
    def __init__(self, in_dim=2, hidden=16, out_dim=1):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(in_dim, hidden),
            nn.ReLU(),
            nn.Linear(hidden, hidden),
            nn.ReLU(),
            nn.Linear(hidden, out_dim),
        )

    def forward(self, x):
        return self.net(x).squeeze(-1)


def train(model, X, y, epochs=200):
    criterion = nn.BCEWithLogitsLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
    for epoch in range(1, epochs + 1):
        optimizer.zero_grad()
        logits = model(X)
        loss = criterion(logits, y)
        loss.backward()
        optimizer.step()
        if epoch % 50 == 0:
            print(f"epoch {epoch:3d}  loss {loss.item():.4f}")
            time.sleep(0.8)


if __name__ == "__main__":
    print("=== MLP  make_moons  2-16-16-1 ===")
    X, y = make_moons()
    model = MLP()
    train(model, X, y)
    with torch.no_grad():
        preds = (model(X) > 0).float()
    acc = (preds == y).float().mean().item()
    print(f"accuracy {acc:.4f}")
