# Learning GCloud and Terraform

GCPとTerraformを使用したインフラストラクチャとアプリケーションのデプロイプロジェクト

## 初期設定

```bash
make
```

※`make` を実行すると、以下が自動的にインストール・設定されます：

- **uv**: 超高速Pythonツールマネージャー
- **tfenv**: Terraformバージョン管理
- **terraform**: 必要なバージョン（.terraform-versionから）
- **pre-commit**: Git hooks管理
- **Git hooks**: コミット/プッシュ時の自動チェック


## プロジェクト構成

```
.
├── app/                    # Flaskアプリケーション
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
├── Makefile
└── README.md              # このファイル
```

