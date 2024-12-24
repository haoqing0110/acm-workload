### Usage

Generate 10 clusters and resources. 

```bash
 ./run.sh apply 10
```

Delete 10 clusters and resources. 

```bash
 ./run.sh delete 10
```

### Analysis

on the hub
```bash
git clone git@github.com:haoqing0110/acm-inspector.git
cd acm-inspector
git checkout br_hub-analysis
```

```bash
# pip3 install kubernetes colorama prometheus-api-client tabulate
# pip3 install 'urllib3<2.0.0'
OC_CLUSTER_URL=<cluser-url> OC_TOKEN=<token> ./src/supervisor/helper.sh > logs
```

Then filter the pod cpu and memory from logs. 