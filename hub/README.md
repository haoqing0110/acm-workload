### Usage

Generate 10 managedclusterview and managedclusteraction on cluster1.

```bash
./run.sh apply resource.yaml 10 cluster1
managedclusterview.view.open-cluster-management.io/my-mcv-1 created
managedclusteraction.action.open-cluster-management.io/my-action-create-1 created
managedclusterview.view.open-cluster-management.io/my-mcv-2 created
managedclusteraction.action.open-cluster-management.io/my-action-create-2 created
managedclusterview.view.open-cluster-management.io/my-mcv-3 created
managedclusteraction.action.open-cluster-management.io/my-action-create-3 created
managedclusterview.view.open-cluster-management.io/my-mcv-4 created
managedclusteraction.action.open-cluster-management.io/my-action-create-4 created
managedclusterview.view.open-cluster-management.io/my-mcv-5 created
managedclusteraction.action.open-cluster-management.io/my-action-create-5 created
managedclusterview.view.open-cluster-management.io/my-mcv-6 created
managedclusteraction.action.open-cluster-management.io/my-action-create-6 created
managedclusterview.view.open-cluster-management.io/my-mcv-7 created
managedclusteraction.action.open-cluster-management.io/my-action-create-7 created
managedclusterview.view.open-cluster-management.io/my-mcv-8 created
managedclusteraction.action.open-cluster-management.io/my-action-create-8 created
managedclusterview.view.open-cluster-management.io/my-mcv-9 created
managedclusteraction.action.open-cluster-management.io/my-action-create-9 created
managedclusterview.view.open-cluster-management.io/my-mcv-10 created
managedclusteraction.action.open-cluster-management.io/my-action-create-10 created
```

Delete 10 managedclusterview and managedclusteraction on cluster1.

```bash
./run.sh delete resource.yaml 10 cluster1
managedclusterview.view.open-cluster-management.io "my-mcv-1" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-1" not found
managedclusterview.view.open-cluster-management.io "my-mcv-2" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-2" not found
managedclusterview.view.open-cluster-management.io "my-mcv-3" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-3" not found
managedclusterview.view.open-cluster-management.io "my-mcv-4" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-4" not found
managedclusterview.view.open-cluster-management.io "my-mcv-5" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-5" not found
managedclusterview.view.open-cluster-management.io "my-mcv-6" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-6" not found
managedclusterview.view.open-cluster-management.io "my-mcv-7" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-7" not found
managedclusterview.view.open-cluster-management.io "my-mcv-8" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-8" not found
managedclusterview.view.open-cluster-management.io "my-mcv-9" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-9" not found
managedclusterview.view.open-cluster-management.io "my-mcv-10" deleted
Error from server (NotFound): error when deleting "STDIN": managedclusteractions.action.open-cluster-management.io "my-action-create-10" not found
```

Generate 10 failed managedclusterview and managedclusteraction on cluster1.

```bash
$./run.sh apply resource-failure.yaml 10 cluster1
managedclusterview.view.open-cluster-management.io/my-fake-mcv-1 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-1 created
managedclusterview.view.open-cluster-management.io/my-fake-mcv-2 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-2 created
managedclusterview.view.open-cluster-management.io/my-fake-mcv-3 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-3 created
managedclusterview.view.open-cluster-management.io/my-fake-mcv-4 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-4 created
managedclusterview.view.open-cluster-management.io/my-fake-mcv-5 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-5 created
managedclusterview.view.open-cluster-management.io/my-fake-mcv-6 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-6 created
managedclusterview.view.open-cluster-management.io/my-fake-mcv-7 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-7 created
managedclusterview.view.open-cluster-management.io/my-fake-mcv-8 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-8 created
managedclusterview.view.open-cluster-management.io/my-fake-mcv-9 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-9 created
managedclusterview.view.open-cluster-management.io/my-fake-mcv-10 created
managedclusteraction.action.open-cluster-management.io/my-fake-action-create-10 created
```
