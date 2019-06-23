locals {
  mongo_resource_name = "mongodb-enterprise-operator"
  namespace = "mongodb"
}

resource "kubernetes_namespace" "mongo_namespace" {
  metadata {
    name = "${local.mongo_resource_name}"
  }
}


resource "kubernetes_role" "mongo_role" {
  metadata {
    name = "${local.mongo_resource_name}"
    namespace = "${kubernetes_namespace.mongo_namespace.metadata.name}"
  }

  rule {
    api_groups = [
      ""]
    resources = [
      "configmaps",
      "secrets",
      "services"]
    verbs = [
      "get",
      "list",
      "create",
      "update",
      "delete",
      "watch"]
  }
  rule {
    api_groups = [
      "apps"]
    resources = [
      "statefulsets"]
    verbs = [
      "get",
      "list",
      "create",
      "update",
      "delete",
      "watch"]
  }
  rule {
    api_groups = [
      "mongodb.com"]
    resources = [
      "mongodb",
      "mongodb/finalizers",
      "mongodbusers"]
    verbs = [
      "get",
      "list",
      "create",
      "update",
      "delete",
      "watch"]
  }
}

resource "kubernetes_role_binding" "mongo_role_binding" {

  metadata {
    name = "${local.mongo_resource_name}"
    namespace = "${kubernetes_namespace.mongo_namespace.metadata.name}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "Role"
    name = "${local.mongo_resource_name}"
  }
  subject {
    kind = "ServiceAccount"
    name = "${local.mongo_resource_name}"
  }
}

resource "kubernetes_cluster_role" "mongo_cluster_role" {
  metadata {
    name = "${local.mongo_resource_name}"
  }

  rule {
    api_groups = [
      "certificates.k8s.io"]
    resources = [
      "certificatesigningrequests"]
    verbs = [
      "get",
      "create",
      "list",
      "watch"]
  }
}

resource "kubernetes_cluster_role_binding" "mongo_cluster_role_binding" {
  metadata {
    name = "mongodb-enterprise-operator-mongodb-certs-binding"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = "${kubernetes_cluster_role.mongo_cluster_role.metadata.name}"
  }
  subject {
    kind = "ServiceAccount"
    name = "${local.mongo_resource_name}"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "kubernetes_service_account" "mongo_account_service" {
  metadata {
    name = "${local.mongo_resource_name}"
    namespace = "${kubernetes_namespace.mongo_namespace.metadata.name}"
  }
}

resource "kubernetes_deployment" "mongo_deployment" {
  metadata {
    name = "${local.mongo_resource_name}"
    namespace = "${kubernetes_namespace.mongo_namespace.metadata.name}"
  }

  spec {
    replicas = 3

    selector {
      match_labels {
        app = "${local.mongo_resource_name}"
      }
    }

    template {
      metadata {
        labels {
          app = "${local.mongo_resource_name}"
        }
      }

      spec {
        service_account_name = "${kubernetes_service_account.mongo_account_service.metadata.name}"
        security_context {
          run_as_non_root = true
          run_as_user = 2000
        }
        container {
          image = "quay.io/mongodb/mongodb-enterprise-operator:1.0"
          name = "${local.mongo_resource_name}"
          env {
            name = "OPERATOR_ENV"
            value = "prod"
          }
          env {
            name = "MONGODB_ENTERPRISE_DATABASE_IMAGE"
            value = "quay.io/mongodb/mongodb-enterprise-database:1.0"
          }
          env {
            name = "IMAGE_PULL_POLICY"
            value = "Always"
          }
        }
      }
    }
  }
}