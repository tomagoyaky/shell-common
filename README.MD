# shell-common 项目说明

## 项目简介

本项目为一组通用 Shell 脚本及相关目录结构，旨在为自动化运维、数据处理、环境搭建等场景提供基础支持。适用于需要批量处理、自动化部署、数据管理等需求的用户。

## 目录结构
例如项目mem0
```
common.sh                # 通用 shell 脚本
python.common.sh         # Python 相关通用脚本
start.mem0.sh            # 启动脚本示例
workspace/               # 工作区目录
  mem0/
    data/                # 数据目录
    input/               # 输入文件目录
    logs/                # 日志目录
    output/              # 输出文件目录
    sources/             # 源文件目录
    status/              # 状态文件目录
      filesystem.ok.status  # 文件系统状态标记
      venv.ok.status        # 虚拟环境状态标记
    tars/                 # 归档文件目录
    tmp/                  # 临时文件目录
```

## 使用方法

1. 克隆本仓库到本地：
   ```bash
   git clone https://github.com/tomagoyaky/shell-common.git
   ```
2. 进入项目目录，根据实际需求修改和使用各类脚本。
3. 运行示例：
   ```bash
   bash start.mem0.sh
   ```

## 依赖环境
- Bash shell 环境（推荐在 Linux 或 WSL 下使用）
- Python（如需运行 python.common.sh 相关脚本）

## 贡献说明
欢迎提交 issue 或 pull request 以完善本项目。

## 许可证
本项目采用 MIT License。
