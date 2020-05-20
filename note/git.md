# 使用Git进行大文件存储

[lfs使用教程](https://www.escapelife.site/posts/92ef32ff.html)

## 安装lfs

```bash
$ curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
$ sudo apt-get install git-lfs
$ git lfs install
```

## 快速使用

```bash
# 1.开启lfs功能
$ git lfs install

# 2.追踪所有后缀名为“.psd”的文件
$ git lfs track "*.iso"

# 3.追踪单个文件
git lfs track "logo.png"

# 4.提交存储信息文件
$ git add .gitattributes

# 5.提交并推送到GitHub仓库
$ git add .
$ git commit -m "Add some files"
$ git push origin master
```

## 常用命令

| 编号 | 命令               | 含义解释                              |
| ---- | ------------------ | ------------------------------------- |
| 1    | `git lfs track`    | 查看或添加 LFS 路径到 attributes 文件 |
| 2    | `git lfs untrack`  | 从 attributes 文件中删除 LFS 路径     |
| 3    | `git lfs ls-files` | 查看 LFS 中跟踪的文件列表             |
| 4    | `git lfs status`   | 在工作树中显示 LFS 文件的状态         |
| 5    | `git lfs fetch`    | 从远程仓库下载 LFS 文件               |
| 6    | `git lfs pull`     | 获取最新的 LFS 对象当本地仓库         |
| 7    | `git lfs push`     | 推送本地的 LFS 修改到远程仓库         |
| 8    | `git lfs checkout` | 本地 LFS 分支切换                     |
| 9    | `git lfs clone`    | 克隆包含 LFS 文件的 Git 远程仓库      |
| 10   | `git lfs update`   | 更新当前 Git 仓库的 hooks 地址        |
| 11   | `git lfs version`  | 显示 LFS 的版本号                     |
| 12   | `git lfs env`      | 显示 LFS 的环境变量                   |
| 13   | `git lfs prune`    | 删除全部旧的 LFS 文件                 |

```bash
# 克隆包含“Git LFS”文件的远程仓库到本地
$ git clone git@gitlab.example.com:group/project.git

# 已经克隆了仓库且想要获取远程存储库中的最新LFS对象
$ git lfs fetch origin master

# 获取最新的LFS对象当本地仓库
$ git lfs pull

# 推送本地的LFS修改到远程仓库
$ git lfs push
```