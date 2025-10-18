# Learning GCloud and Terraform

GCPとTerraformを使用したインフラストラクチャとアプリケーションのデプロイプロジェクト

## プロジェクト構成

```
.
├── app/                    # Djangoアプリケーション
├── env/                    # 環境別インフラ設定
│   ├── deploy/            # デプロイ関連リソース
│   └── dev/               # 開発環境
│       ├── vpc/           # VPCネットワーク
│       ├── iam/           # IAM設定
│       ├── db/            # Cloud SQL
│       ├── cloudrun/      # Cloud Run
│       └── loadbalancer/  # Load Balancer
└── modules/               # 再利用可能なTerraformモジュール
    ├── vpc/
    ├── iam/
    ├── db/
    ├── cloudrun/
    └── loadbalancer/
```

## 必要な環境

- Terraform >= 1.5.0
- Python 3.11+
- Docker
- gcloud CLI

## 開発環境のセットアップ

### 1. Git Hooksのセットアップ（重要）

リポジトリをクローンしたら、まずGit hooksを設定してください：

```bash
make setup-hooks
```

これにより、`git push`実行時に自動的に以下が実行されます：
- `make fmt`: コードの自動フォーマット
- `make lint`: Linterチェック

**フックの動作**:
- pushする前に自動でコードをフォーマット
- Linterエラーがあればpushをブロック
- 緊急時は `git push --no-verify` でバイパス可能（非推奨）

### 2. Linterのインストール

#### Terraform
```bash
# TFLintのインストール（macOS）
brew install tflint

# TFLintの初期化
tflint --init
```

#### Python
```bash
# Python Linterのインストール
pip install black flake8 isort
```

### 3. Linterの実行

プロジェクトルートで以下のコマンドを実行：

```bash
# すべてのLinterを実行
make lint

# Terraformのみ
make lint-tf

# Pythonのみ
make lint-py
```

### 4. コードフォーマット

```bash
# すべてのコードをフォーマット
make fmt

# Terraformのみ
make fmt-tf

# Pythonのみ
make fmt-py
```

## CI/CD

### GitHub Actions

PRを作成すると、以下のチェックが自動実行されます：

- **Terraform Checks**
  - `terraform fmt -check -recursive`: フォーマットチェック
  - `tflint`: 静的解析

- **Python Checks**
  - `black --check`: コードフォーマットチェック
  - `isort --check`: インポート順序チェック
  - `flake8`: リンティング

### PRテンプレート

PRを作成すると、自動的にチェックリストが表示されます。PRマージ前に以下を確認してください：

- [ ] `make lint` が通ること
- [ ] `make fmt` でコードがフォーマットされていること
- [ ] `terraform plan` で意図しない変更がないこと

## デプロイ

### インフラのデプロイ

```bash
# 開発環境へのデプロイ
cd env/dev/<resource>
terraform init
terraform plan
terraform apply
```

### アプリケーションのデプロイ

```bash
# Dockerイメージのビルドとプッシュ
make build

# または直接
cd app
make buildpush
```

## 便利なコマンド

```bash
make help           # 利用可能なコマンド一覧を表示
make setup-hooks    # Git hooksを設定（初回のみ）
make check-hooks    # Git hooksが設定されているか確認
make lint           # すべてのLinterを実行
make lint-tf        # Terraformのみlint
make lint-py        # Pythonのみlint
make fmt            # すべてのコードをフォーマット
make fmt-tf         # Terraformのみフォーマット
make fmt-py         # Pythonのみフォーマット
make build          # Dockerイメージをビルド＆プッシュ
```

## モジュールの使い方

各モジュールは再利用可能な設計になっています：

```hcl
module "vpc" {
  source = "../../../modules/vpc"

  project_id              = var.project_id
  region                  = var.region
  network_name            = "vpc-network"
  subnetwork_name         = "subnetwork"
  ip_cidr_range           = "10.0.0.0/24"
  auto_create_subnetworks = false
}
```

詳細は各モジュールのREADMEを参照してください。

## トラブルシューティング

### Linterエラーが出る場合

1. フォーマットを実行: `make fmt`
2. エラーメッセージを確認して修正
3. 再度Linterを実行: `make lint`

### Terraform Validateエラー

```bash
cd <該当ディレクトリ>
terraform init
terraform validate
```

## ライセンス

MIT
