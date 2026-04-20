/// 

function laboratory_test() {
    var _laboratory_manager = new LaboratoryManager()
    var result = _laboratory_manager.load_all_stages()
    if (result.is_failed()) {
        throw(result.message)
    }
    show_debug_message("[TEST] load all stages succeed")
    
    _laboratory_manager.reset()
}