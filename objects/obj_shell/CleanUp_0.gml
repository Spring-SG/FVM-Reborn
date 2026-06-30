// feather disable all
// feather ignore all
surface_free(shellSurface);
if (ds_exists(deferredQueue, ds_type_queue)) {
	ds_queue_destroy(deferredQueue);
}
