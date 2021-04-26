# auto-generate-cert
自动生成证书脚本

## 用法
1. 编辑脚本，设置可信任的域名和IP地址，如下：
```
DOMAIN=test1.zerchin.xyz
DOMAIN_EXT=test2.zerchin.xyz,test3.zerchin.xyz
IP=172.16.1.188,172.16.1.189
DATE=3650
```
参数说明：

`DOMAIN`：必填项，证书的域名

`DOMAIN_EXT`：可选，额外的域名，多个域名以逗号隔开，没有则留空

`IP`：可选，可信任的IP地址，多个IP地址以逗号隔开，没有则留空

`DATE`：证书有效期，默认是10年


2. 执行脚本
```bash
bash auto-generate-cert.sh
```
