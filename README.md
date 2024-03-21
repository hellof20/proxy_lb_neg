# regional_proxy_lb_internet_neg
通过GCP的premium网络实现部署在其他云上的TCP端口加速

## 优势
- 不需要GCP和其他云打通
- 就近上车，就近下车
- 架构简单

## 架构
<img width="898" alt="image" src="https://github.com/hellof20/regional_proxy_lb_internet_neg/assets/8756642/f1eedb6d-5ee1-4e59-8368-28f4a19e5df7">

## 使用
1. 将期望的mapping关系写到mapping.csv文件中，csv中每一列的含义：游戏服名称,游戏服公网IP,游戏服端口,LB端口
2. 修改项目等信息
```
bash regional_proxy_lb_neg.sh
```
