# Note

DB初回起動時はIAM認証ユーザーにDB作成権限が付与されていないため、管理ユーザーを使用して付与する必要がある。
現在は踏み台GCEインスタンスのスタートアップスクリプトが自動でCloud SQL Proxyを起動し、必要なGRANT文を実行する。

## 初回権限付与の流れ

- `terraform apply` で Cloud SQL と Bastion を作成すると、起動時に自動で権限付与が実行される。
- 完了すると `/tmp/setup_complete` ファイルが作成されるので、必要に応じて確認する。

## 権限付与を再実行したい場合

再実行が必要な場合は踏み台サーバー上で以下を実行する。

```bash
gcloud compute ssh bastion-default \
  --zone=asia-northeast1-a \
  --project=gcloud-and-terraform \
  --tunnel-through-iap

sudo rm -f /var/tmp/db_grants_applied
sudo systemctl restart google-startup-scripts.service

exit
```

リスタート後に `/tmp/setup_complete` が更新され、権限付与が再度実行される。

## 踏み台からCloudSQLへのログイン方法

踏み台用のIAM認証を用意しているのでそれを使用してログインする


```
export INSTANCE_CONNECTION_NAME="gcloud-and-terraform:asia-northeast1:database-default"
cloud-sql-proxy  --private-ip  --auto-iam-authn   --run-connection-test   --port 5432   --address 127.0.0.1   "$INSTANCE_CONNECTION_NAME"
tomohico_takahashi_gmail_com@bastion-default:~$ psql -h 127.0.0.1 -p 5432 -U bastion@gcloud-and-terraform.iam -d postgres
```
