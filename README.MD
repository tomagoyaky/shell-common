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

### 1. 克隆本仓库到本地
```bash
git clone https://github.com/tomagoyaky/shell-common.git
```

### 2. 进入项目目录，根据实际需求修改和使用各类脚本

### 3. 使用 `start.sh` 快速初始化新项目

#### 脚本参数说明

| 参数 | 说明 |
| ---- | ---- |
| your_project_name | 项目名称（如 demo、mem0、agent 等）|
| -p   | 启用 Python 支持（可选）|
| -d   | 启用 Docker 支持（可选）|

#### 用法示例

```bash
# 初始化一个名为 demo 的项目
bash start.sh demo

# 初始化并启用 Python 支持
bash start.sh demo -p

# 初始化并启用 Docker 支持
bash start.sh demo -d

# 同时启用 Python 和 Docker 支持
bash start.sh demo -p -d
```

#### 交互式输入
如未指定参数，脚本会提示输入项目名、镜像名、容器名、工作区路径等。

#### 初始化流程
1. 自动创建项目目录及 workspace 目录结构
2. 自动复制模板文件（container.template、start.template）到新项目目录
3. 自动生成启动脚本（如 start.demo.sh），并替换模板变量
4. 根据参数自动加载 Python/Docker 支持脚本

#### 多项目支持
可在 `projects/` 下管理多个子项目，每个项目拥有独立的启动脚本和 workspace 目录。

### 4. 运行项目
进入对应项目目录，执行生成的启动脚本：
```bash
cd projects/demo
./start.demo.sh
```


## 依赖环境
- Bash shell 环境（推荐在 Linux、WSL 或 macOS 下使用，Windows 需安装 bash）
- Python（如需运行 python.common.sh 相关脚本）


## 贡献说明
欢迎提交 issue 或 pull request 以完善本项目。

## 许可证
本项目采用 MIT License。
