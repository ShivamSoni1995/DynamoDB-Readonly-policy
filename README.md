
* A DynamoDB table (`my-app-table`)
* An IAM role + instance profile with **least privilege policy** (only `GetItem` & `Query` on that table)
* An EC2 instance with that IAM role attached

## ✅ How to Test

1. Run:

   ```bash
   terraform init
   terraform apply -auto-approve
   ```

2. SSH into the EC2 instance:

   ```bash
   ssh -i your-key.pem ec2-user@<EC2_PUBLIC_IP>
   ```

3. Install AWS CLI (if not preinstalled):

   ```bash
   sudo yum install -y awscli
   ```

4. Test access:

   * **Allowed:**

     ```bash
     aws dynamodb query --table-name my-app-table --key-condition-expression "id = :v1" --expression-attribute-values '{":v1":{"S":"123"}}'
     ```
   * **Denied:**

     ```bash
     aws dynamodb scan --table-name my-app-table
     ```

     → should give an *AccessDenied* error ✅

---

⚡ This gives you a **realistic IAM + EC2 + DynamoDB production-like lab** where you can see how **least privilege roles** work.

---


