# Learning GCloud and Terraform

GCPとTerraformを使用したインフラストラクチャとアプリケーションのデプロイプロジェクト

## 🚀 クイックスタート（1コマンド）

```bash
make
```

**これだけです！**以降は普通のgitコマンドを使うだけ。

---

## 📝 日常的な開発

```bash
git commit -m "fix"     # コミット（軽量チェックのみ、高速！）
git push                # プッシュ（自動でlint実行）
```

**それだけです！**`make` は初回のみ。以降は普通の `git` コマンドだけ。

💡 **Git Hooksが自動で動く**
- `git commit`: 軽量チェック（末尾空白、改行、YAMLなど）
- `git push`: 全lintチェック（Terraform, Python, etc）

---

## 🎯 思想：認知負荷ゼロ

このプロジェクトは、開発者が**考えることを最小限にする**よう設計されています：

### ❌ 従来の開発フロー
```bash
# 1. 何かをインストール（何をインストールするか調べる）
brew install X Y Z

# 2. セットアップ（手順を調べる）
pyenv install 3.11
pipx install pre-commit
...

# 3. コミット前に手動でLint（忘れがち）
terraform fmt -recursive
black .
isort .
flake8 .

# 4. コミット
git add .
git commit -m "..."

# 5. プッシュ前にもう一度チェック？（面倒）
git push
```

### ✅ このプロジェクトの開発フロー
```bash
# 初回のみ
make

# 日々の開発
git commit -m "fix"     # 高速！（軽量チェックのみ）
git push                # 自動lint→プッシュ
```

**終わり。** `make` を一度実行したら、あとは普通の `git` コマンドを使うだけ。
**Git Hooksが全て自動処理** - コミットは高速、プッシュ時に品質保証！

---

## 📚 詳細情報（必要な時だけ）

<details>
<summary><b>💡 自動でインストールされるもの</b></summary>

`make` を実行すると、以下が自動的にインストール・設定されます：

- ✅ **uv**: 超高速Pythonツールマネージャー
- ✅ **tfenv**: Terraformバージョン管理
- ✅ **terraform**: 必要なバージョン（.terraform-versionから）
- ✅ **pre-commit**: Git hooks管理
- ✅ **Git hooks**: コミット/プッシュ時の自動チェック

すべて自動。何も考える必要はありません。

</details>

<details>
<summary><b>🎨 使用可能なコマンド一覧</b></summary>

```bash
# 🚀 初回セットアップ
make (setup)      # 全自動セットアップ

# 📝 日常開発
git commit        # コミット（自動で軽量チェック）
git push          # プッシュ（自動でlint実行）

# 🔧 便利コマンド
make lint         # 手動でlint実行
make fmt          # コード整形
make check        # 環境チェック
make update       # ツール更新
make clean        # キャッシュ削除
make reset        # 完全リセット

# 📦 デプロイ
make build        # Dockerビルド＆プッシュ

# 📚 ヘルプ
make help         # コマンド一覧表示
```

</details>

<details>
<summary><b>🏗️ プロジェクト構成</b></summary>

```
.
├── app/                    # Djangoアプリケーション
├── env/                    # 環境別インフラ設定
│   └── dev/               # 開発環境
│       ├── vpc/           # VPCモジュール使用
│       ├── iam/           # IAMモジュール使用
│       ├── db/            # DBモジュール使用
│       ├── cloudrun/      # Cloud Runモジュール使用
│       └── loadbalancer/  # LBモジュール使用
├── modules/               # 再利用可能なTerraformモジュール
│   ├── vpc/
│   ├── iam/
│   ├── db/
│   ├── cloudrun/
│   └── loadbalancer/
├── .pre-commit-config.yaml # Linter設定
├── pyproject.toml         # Python依存関係
├── Makefile               # 全自動化の核心
└── README.md              # このファイル
```

</details>

<details>
<summary><b>🔧 カスタマイズ</b></summary>

### Linterの設定変更

`.pre-commit-config.yaml` を編集してください。変更後：

```bash
make update    # 設定を反映
```

### Terraformバージョン変更

`.terraform-version` を編集してください。次回 `make` 実行時に自動適用されます。

### Pythonバージョン変更

`.python-version` を編集してください（オプション）。

</details>

<details>
<summary><b>🐛 トラブルシューティング</b></summary>

### 問題が発生したら

```bash
make reset    # 完全リセット
make          # 再セットアップ
```

### 環境をチェックしたい

```bash
make check
```

### それでも解決しない場合

1. このリポジトリをクローンし直す
2. `make` を実行
3. それでもダメなら Issue を開いてください

</details>

<details>
<summary><b>🎓 技術スタック（興味がある人向け）</b></summary>

### インフラ
- **Terraform**: IaC（Infrastructure as Code）
- **GCP**: Cloud Provider
- **モジュール設計**: 再利用可能な構成

### CI/CD
- **pre-commit**: Git hooks管理
- **GitHub Actions**: 自動テスト
- **uv**: 超高速Pythonツール管理

### 開発体験
- **Makefile**: 全自動化
- **認知負荷ゼロ設計**: コマンドを覚える必要がない
- **自動修復**: Lintエラーを自動修正

</details>

<details>
<summary><b>❓ FAQ</b></summary>

**Q: なぜ `make` だけで全て動くの？**
A: Makefileが依存関係を自動チェック・インストールするように設計されています。

**Q: グローバル環境を汚染しない？**
A: はい。uvとtfenvだけがグローバルインストールされ、他は全て隔離環境です。

**Q: 既存のプロジェクトに導入できる？**
A: はい。`.pre-commit-config.yaml`と`Makefile`をコピーして`make`を実行してください。

**Q: WindowsでもOK？**
A: WSL2を使用すれば動作します。ネイティブWindows対応は現在未対応です。

**Q: カスタムLinterを追加したい**
A: `.pre-commit-config.yaml`に追加して `make update` を実行してください。

</details>

---

## 🤝 コントリビューション

PR歓迎！以下を実行するだけ：

```bash
make c    # 自動lint→コミット
make p    # 自動lint→プッシュ→PR作成
```

---

## 📄 ライセンス

MIT

---

## 💡 Philosophy

> "The best developer experience is the one you don't have to think about."

このプロジェクトは、開発者が**本質的な問題解決に集中できる**よう、
インフラ・ツール・ワークフローの**認知負荷を極限まで減らす**ことを目指しています。

**覚えるコマンド**:
- `make` - 初回セットアップのみ（一度だけ）
- `git commit -m "..."` - 普通のコミット
- `git push` - 普通のプッシュ

**それだけ。** 特別なコマンドを覚える必要なし。普通の `git` コマンドを使うだけ。

**Git Hooksが全て自動処理**:
- コミット時: 軽量チェック（高速）
- プッシュ時: 全lintチェック（品質保証）
