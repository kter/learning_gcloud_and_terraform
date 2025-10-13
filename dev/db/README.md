# Note

DB初回起動時はIAM認証ユーザーにDB作成権限が付与されていないため、管理ユーザーを使用して付与する必要がある。
管理ユーザーは踏み台GCE経由でアクセスする。

## 手順

スクリプト(terraform applyで生成される)をGCEにコピー

```bash
gcloud compute scp grant_permissions_on_bastion.sh bastion-default:/tmp/ \
  --zone=asia-northeast1-a \
  --project=gcloud-and-terraform \
  --tunnel-through-iap
```

踏み台サーバーにログイン

```bash
gcloud compute ssh bastion-default \
  --zone=asia-northeast1-a \
  --project=gcloud-and-terraform \
  --tunnel-through-iap
```

踏み台サーバーで権限付与スクリプトを実行

```bash
# セットアップが完了するまで待つ（初回起動時のみ）
cat /tmp/setup_complete

# 権限付与スクリプトを実行
chmod +x /tmp/grant_permissions_on_bastion.sh
/tmp/grant_permissions_on_bastion.sh

# 完了したらログアウト
exit
```

ここまで来るとIAM認証ユーザーに権限が付与されるため、以下コマンドでマイグレートを実行できる

```bash
cd /Users/ttakahashi/workspace/learning_gcloud_and_terraform/dev/container
make  # Dockerイメージをビルド＆プッシュ

cd /Users/ttakahashi/workspace/learning_gcloud_and_terraform/dev/cloudrun
terraform apply  # Cloud Runサービスをデプロイ

# マイグレーション実行
gcloud run jobs execute db-migrate --region asia-northeast1
```
