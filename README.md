# proxy_lb_neg

## 方式一: Regional proxy lb + Internet NEG
通过GCP的premium网络实现部署在其他云上的TCP端口加速

### 优势
- 不需要GCP和其他云打通
- 就近上车，就近下车
- 架构简单

### 架构
<img width="898" alt="image" src="https://github.com/hellof20/regional_proxy_lb_internet_neg/assets/8756642/f1eedb6d-5ee1-4e59-8368-28f4a19e5df7">

## 使用
1. 将期望的mapping关系写到mapping.csv文件中，csv中每一列的含义：游戏服名称,游戏服公网IP,游戏服端口,LB端口
2. 修改regional_proxy_lb_internet_neg.sh文件中的项目，区域，网络等信息
```
bash regional_proxy_lb_internet_neg.sh
```

## 方式二: Global proxy lb + Hybrid NEG
通过GCP Global proxy lb的Anycast IP结合premium网络实现对部署在其他云上的TCP端口加速

#### 要求
- GCP和其他云通过专线或者VPN打通

#### 优势
- TCP连接终结在边缘测
- 就近上车，就近下车
- 抗DDoS能力更强

## 使用
1. 将期望的mapping关系写到mapping.csv文件中，csv中每一列的含义：游戏服名称,游戏服公网IP,游戏服端口,LB端口
2. 修改global_proxy_lb_hybrid_neg.sh文件中的项目等信息
```
bash global_proxy_lb_hybrid_neg.sh
```
