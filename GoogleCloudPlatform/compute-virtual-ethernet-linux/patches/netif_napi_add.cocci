@@
expression dev, napi, func, weight;
@@

netif_napi_add(dev, napi, func, weight);
+#if LINUX_VERSION_CODE < KERNEL_VERSION(4,5,0) && LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0)
+napi_hash_add(napi);
+#endif /* LINUX_VERSION_CODE < KERNEL_VERSION(4,5,0) && LINUX_VERSION_CODE >= KERNEL_VERSION(3,11,0) */
