# TODO App

シンプルなTODOアプリケーション（Django + PostgreSQL）

## ローカル開発環境のセットアップ

### 1. Docker Composeで起動

```bash
cd /Users/ttakahashi/workspace/learning_gcloud_and_terraform/app
docker-compose up -d
```

### 2. マイグレーションを実行

```bash
docker-compose exec web python manage.py makemigrations
docker-compose exec web python manage.py migrate
```

### 3. スーパーユーザーを作成（オプション）

```bash
docker-compose exec web python manage.py createsuperuser
```

### 4. アプリケーションにアクセス

- TODOアプリ: http://localhost:8000
- 管理画面: http://localhost:8000/admin

## GCP Cloud Runへのデプロイ

### 必要な環境変数

Cloud Run環境では以下の環境変数が必要です（Terraformで自動設定されます）:

- `ENV=dev` (または prod)
- `DB_NAME`: データベース名
- `DB_USER`: IAMサービスアカウント名
- `DB_HOST`: Cloud SQLのプライベートIPアドレス
- `DB_PORT`: 5432
- `INSTANCE_CONNECTION_NAME`: Cloud SQLインスタンス接続名 (project:region:instance)
- `ALLOWED_HOSTS`: 許可するホスト名

### デプロイ手順

1. Dockerイメージをビルド＆プッシュ:

```bash
cd app
docker build -t asia-northeast1-docker.pkg.dev/PROJECT_ID/django-app/app:latest .
docker push asia-northeast1-docker.pkg.dev/PROJECT_ID/django-app/app:latest
```

2. Terraformでデプロイ:

```bash
cd env/dev/cloudrun
terraform apply
```

3. マイグレーションを実行（初回のみ）:

Cloud Runコンテナに接続してマイグレーションを実行します。

## 機能

- TODOの作成、表示、完了/未完了の切り替え、削除
- PostgreSQLデータベースへの永続化
- ローカル: 通常のPostgreSQL接続
- GCP: Cloud SQL Python ConnectorとIAM認証

## API

- `GET /api/list/`: TODO一覧をJSON形式で取得
