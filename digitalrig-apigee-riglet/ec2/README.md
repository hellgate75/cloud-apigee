
# ApiGee Server EC2 Eco-system RIGLET Domain

Here the project with the purpose of creating a base, extendable rancher server domain with pipelines on ApiGee RIG Orchestration Server. Development/Study environment.

## Prerequisites
* Ansible 2.2+
* AWS CLI with configured creds (`aws configure`)
* Terraform
* knock (v0.7)
* Python packages
    * boto
    * pywinrm
    * six

## Install
To build the rig on EC2:

0. Configure parameters in `inputs`

    * `tf_config_path`: by default should point to `digital-riglet-instances/rancher.riglet`. If you need to edit this, duplicate it and modify the new file.
    * `region`
    * `ansible-domain`: unique identifier for your riglet, e.g. `<initial><lastname>.rancher.riglet` or `<team name>.rancher.riglet`
    * `public-availability-zone` and `internal_availability_zone`: check your region to see what's available. These **must** be different.
    * `internal_keypair` and `keypair`: they are not named the same in each region(!). Create your own with your private key in the AWS EC2 console -> Network and Security -> Key Pairs then add key pair.., please provide a standard name such as : <initial><lastname>-<region>-keypair (It's suitable to create one key pair with you pubic key and save the name in the inputs file)
    * `ad_password:`: define administrative password for AD and the same you can use to login the OVPN.
    * `route_53_domain_id`: define route 53 domain id (see AWS route 53 section)
    * `route_53_domain_name`: define route 53 domain name  (see AWS route 53 section)
    * `ad_krb_realm`: Uppercase AD Realm
    * `krb_domain`: Lowercase AD domain
    * `base_dn`: Base DN user to store credentials
    * `edgemicro_org`: define APIGee Organization
    * `edgemicro_env`: define APIGee Environment (test/prod/..)
    * `edgemicro_user`: define APIGee Edge user (developer or admin)
    * `edgemicro_pass`: define APIGee Edge user password
    * `edgemicro_consumer_credentials`: define comma separated list of column separated couple of application key/token
    * `edgemicro_private_cloud`: yes|no (switch to private cloud)
    * `edgemicro_router`: URL to Edge Gateway Router  (ex: http://myorg.myenv.apigee.net)
    * `edgemicro_api_mngmt`: URL to API Management Server (ex: http://myorg.myenv.apigee.net)

0. In case of licensed APIGee account, and virtualhost ssl validation define a new TLS self signed certificate and upload it on APIGee Web Console in ADMIN -> Environment -> TLS Keystore and report SSL certificate and key in [vars file](/digitalrig-apigee-riglet/ec2/vars)  in these variables :
    * apigee_custom_x509_certificate: APIGee custom X509 Self signed certificate
    * apigee_custom_x509_certificate_key: APIGee custom X509 Self signed certificate key

    You can define APIGee certificate, as well as you can define X509 Certificate keys (for a self-signed server certificate with common name as the `APIGee organization gateway hostname or IP` [usually you should use the callee, we hope it's sufficient generate a certificate on Font-end ip in the file `/digitalrig-apigee-riglet/ec2/tmp/_tf_outputs.yml` in front-end public ip variable after the TF outputs generation step] for defining remote access to Gateway Port Services and another server certificate with `localhost` common name for defining local access to Gateway Index Services), for instance as follow :

    ## TLS Self-Signed Certificates

    ##### Generate private key (.key)

    ```sh
    # Key considerations for algorithm "RSA" ≥ 2048-bit
    openssl genrsa -out server.key 2048

    # Key considerations for algorithm "ECDSA" ≥ secp384r1
    # List ECDSA the supported curves (openssl ecparam -list_curves)
    openssl ecparam -genkey -name secp384r1 -out server.key
    ```

    ##### Generation of self-signed(x509) public key (PEM-encodings `.pem`|`.crt`) based on the private (`.key`)

    ```sh
    openssl req -new -x509 -sha256 -key server.key -out server.pem -days 3650
    ```

    ## TLS Self-Signed CA Certificates (*NOT TESTED YET*)

    ##### Generate root key (rootCA.key)

    ```sh
    # Key considerations for algorithm "RSA" ≥ 2048-bit
    openssl genrsa -out rootCA.key 2048

    #The standard key sizes today are 1024, 2048, and to a much lesser extent, 4096. We choose a very private key.
    # It's very important to pay attention to common name, it defines the server who has access to the services
    # Common Name (eg, YOUR name) []: 10.0.0.1
    openssl genrsa -des3 -out rootCA.key 2048
    ```

    ##### The next step is to self-sign this certificate
    ```sh
    openssl req -x509 -new -nodes -key rootCA.key -sha256 -days 1024 -out rootCA.pem
    ```

    ##### Generate private key (.key)

    ```sh
    # Key considerations for algorithm "RSA" ≥ 2048-bit
    openssl genrsa -out server.key 2048

    # It's very important to pay attention to common name, it defines the server who has access to the services
    # Common Name (eg, YOUR name) []: 10.0.0.1
    openssl req -new -key server.key -out server.csr
    ```

    ##### Generation of self-signed(x509) public key (PEM-encodings `.pem`|`.crt`) based on the private (`.crs`)

    ```sh
    openssl x509 -req -in server.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out server.crt -days 1024 -sha256
    ```

    Remember you can store new keys in `vars` file in the located at : `/digital-apigee-riglet/ec2/vars`. If you enable custom TLS protection for gateway, APIGee Proxy won't be able to establish any connection on that channel. No TSL thrust protocol has defined in APIGee Reverse Proxy feature.

0. Execute Terraform (parameters from `input` will be passed to TF)
  `ansible-playbook -i ./inventory/localhost -e @vars -e @inputs -e @private ../tf_run.yml`

0. Generate Ansible var file from TF outputs:
  `ansible-playbook -i ./inventory/localhost -e @inputs -e @vars -e @private ../tf_outputs.yml`

0. Define on APIGee gateway web console (DEVELOP) a Proxy named `gateway`, type `reverse proxy`, using the gateway IP (in `/digitalrig-apigee-riglet/etc/tmp/_tf_ouputs` you have an ip address corresponding to the variable named `gateway_public_ip`) and port `10099`. The URL will be pretty much similar to this sampler : `https://xxx.xxx.xxx.xxx:10099/`.

0. Define on APIGee gateway web console an `Access Control` Rule for the Proxy in tab : development -> policies -> Add : `Access Control` and provision on that code soma changes, as follow :
    ```xml
    <IPRules noRuleMatchAction="DENY">
        <MatchRule action="ALLOW">
            <SourceAddress mask="32">$font-end-public-ip</SourceAddress>
        </MatchRule>
    </IPRules>
    ```
    Make the Same on the Gateway APIGee Flow used for the `Gateway` Proxy.
    Replacing the $font-end-public-ip with value in file `/digitalrig-apigee-riglet/etc/tmp/_tf_ouputs` corresponding to the variable named `front_end_public_ip`. In this way the access to your Gateway is allowed only in https and only from front-end Ngnix call (very secure).

0. Define on APIGee gateway web console a Self-Signed certificate in ADMIN -> Environment (prod) -> TLS section :
  Define A TLS Keystore and define a certificate with common name : in file `/digitalrig-apigee-riglet/etc/tmp/_tf_ouputs` corresponding to the variable named `front_end_public_ip` and alternative names all host you want access to APIGee (very secure) and alis name `<myorg>-frontend`. (Repeate previous bullet points to create another identical proxy named `edgemicro_gateway`)

0. Define on APIGee gateway web console (DEVELOP) a Shared Flow and deploy the flow on production [PROD] (Now your proxy is operative).

0. In case of licensed APIGee Edge account you can change the [SSL] Virtual Host [ADMIN -> Environment (prod)] enabling Client Auth and associating the certificate you have just defined (named `<myorg>-frontend`).

0. Define variables in `inputs` file :
    * `apigee_gateway_proxy_url`: APIGee environment Gateway Reverse Proxy url (ex: http://myorg.myenv.apigee.net/gateway)
    * `apigee_edge_proxy_path`: APIGee environment Gateway Reverse Proxy url (ex: http://localhost:8000/edgemicro_gateway)


0. Make sure you're able to open ssh connection to jump host. Command and hostname are the output of "show jump host information" task in the previous step.
   If you can't open ssh connection, please make sure to configure ssh properly. See Troubleshooting section.
   You have to report your AWS API Key/Secret or Token in the just created local folder : digitalrig-rancher-riglet/tmp in order to allow
   Ansible to create contexts and resources under AWS

0. Execute RIG init scripts:
  `ansible-playbook -i ./inventory -e @inputs -e @vars -e @../tmp/_tf_outputs.yml rig.yml`

    If you encounter errors completing this script (it can take a while), consider running each referred script in turn (see `rig.yml`).

 0. Once you are done, connect to VPN (check [section 4a on the wiki](https://digitalrig.atlassian.net/wiki/pages/viewpage.action?pageId=54460451)) and run
  `ansible-playbook -i ./inventory -e @inputs -e @vars -e @../tmp/_tf_outputs.yml on_vpn.yml`
This step will create server features and the Jenkins test pipeline

### Troubleshooting
* In case of failure to download some external package:
     * Retry the execution; and
     * Consider adding retry to the step (`until` in ansible task).

* In case of "UNREACHABLE" error during Ansible execution (by default knockd opens SSH access for 60 minutes):

  0. Knock-knock `ansible-playbook -i ./inventory -e @inputs -e @vars ../knocker.yml`
  0. Re-run required step.
* In case ssh to jump host does not work
  * Configure key authentication for VPC subnet `10.10.243.*` mask and jump host by adding following lines to your ~/.ssh/config
  ```sh
  Host 10.10.243.* <<jump.host.name>>
      User centos
      IdentityFile <<path/to/internal/private/key>>
  ```

### Testing the API Gateway

* call `https://<front-end-public-ip>` -> then click on link 'APIGee Jenkins API Proxy Call'
* call `https://<front-end-public-ip>/apigee` the add discovered service at the end of the path (e.g.: `https://<front-end-public-ip>/apigee/Jenkins` for Jenkins API access thru APIGee proxy)

Use this user account : admin/admin or user/user to authenticate the NGNIX Client Gateway.

The NGINX server access is password protected. You can change with your preferred htpasswd file the dr-script -> digital apigee front-end apps role in folder `files`.

### Related articles

Here some technical material :
* [APIGee Edge explained](http://docs.apigee.com/api-services/content/what-apigee-edge)
* [Watch an official APIGee introduction video](https://youtu.be/LssHa1Y_i0g)
* [Configure APIGee Proxy](http://docs.apigee.com/api-services/content/build-simple-api-proxy)
* [Configure Edge Micro-Gateway](http://docs.apigee.com/microgateway/latest/setting-and-configuring-edge-microgateway)
* [Gateway Software](https://github.com/fabriziotorelli-wipro/go-gateway-reverse/blob/master/README.md)
* [Edge Micro-Gateway Docker Image](https://github.com/fabriziotorelli-wipro/rig-docker-machines/blob/master/2/apigee-edge-microgateway/README.md)
* [Knows more about Buildit] (https://medium.com/buildit)

## Tips
* _-vvvv_ is your friend to understand why your playbook does not work
* It uses mixed dynamic (EC2 tag-based) and static (localhost and group_vars) inventory
* Actual variables `ansible -m setup -i ... host`
* To check ansible registry: `./inventory/ec2.py --list --refresh-cache`

## Destroy

To destroy the infrastructure:

   ```ansible-playbook -i ./inventory/localhost -e @vars -e @inputs -e @private ../tf_destroy.yml```

It will require a yes/no confirmation. As in the actual terraform command, the answer MUST be "yes"
