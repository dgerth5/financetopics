import numpy as np
import pandas as pd

def gbm(s0, u, o, t, steps, sims):
    paths = np.zeros((steps, sims))
    paths[0, :] = s0
    dt = t / steps
    
    for i in range(1, steps):
        paths[i, :] = paths[i - 1, :] * np.exp((u - o ** 2 / 2) * dt + o * np.random.normal(size=sims) * np.sqrt(dt))
    
    return paths

P = gbm(100, 0.5, 0.3, 1, 100, 1000)

def euro_option_prices(paths, r, t, K):
    c = np.zeros(len(K))
    p = np.zeros(len(K))
    
    for i in range(len(K)):
        c[i] = round(np.mean(np.maximum(paths[-1, :] - K[i], 0)) / np.exp(r * t), 2)
        p[i] = round(np.mean(np.maximum(K[i] - paths[-1, :], 0)) / np.exp(r * t), 2)
    
    df = pd.DataFrame({'Strike': K, 'Call_Price': c, 'Put_Price': p})
    return df

print(euro_option_prices(P, 0.01, 1, [95]))
