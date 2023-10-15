rm(list = ls())
options(stringsAsFactors = F)

library(devtools)
library(roxygen2)
library(devtools)

# 1. 手动填写DESCRIPTION文件信息
# 2. 自定义R函数（每次更新R函数，运行 devtools::document() 更新）
# 3. check() 检查
roxygen2::roxygenise() # 根据每个函数和方法上方添加的 roxygen 注释，生成NAMESPACE
check()

