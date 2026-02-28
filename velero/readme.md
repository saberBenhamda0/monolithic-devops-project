create a file called credentials-velero and put ur credentials on it in this format 

[default]
aws_access_key_id = <YOUR_ACCESS_KEY>
aws_secret_access_key = <YOUR_SECRET_KEY>

then run 

kubectl create secret generic velero-credentials \
  --namespace velero \
  --from-file=cloud=credentials-velero