alias ChatProgramming.VectorDatasetItem
origin_dataset_name = "aptos-smart-contracts"
VectorDatasetItem.create(%{
    unique_id: "2b73cfa1-d3fe-48f9-9fb2-99adc82242b3", 
    context: "module hello_blockchain::message {\n    use std::error;\n    use std::signer;\n    use std::string;\n    use aptos_framework::account;\n    use aptos_framework::event;\n\n//:!:>resource\n    struct MessageHolder has key {\n        message: string::String,\n        message_change_events: event::EventHandle<MessageChangeEvent>,\n    }\n//<:!:resource\n\n    struct MessageChangeEvent has drop, store {\n        from_message: string::String,\n        to_message: string::String,\n    }\n\n    /// There is no message present\n    const ENO_MESSAGE: u64 = 0;\n\n    #[view]\n    public fun get_message(addr: address): string::String acquires MessageHolder {\n        assert!(exists<MessageHolder>(addr), error::not_found(ENO_MESSAGE));\n        borrow_global<MessageHolder>(addr).message\n    }\n\n    public entry fun set_message(account: signer, message: string::String)\n    acquires MessageHolder {\n        let account_addr = signer::address_of(&account);\n        if (!exists<MessageHolder>(account_addr)) {\n            move_to(&account, MessageHolder {\n                message,\n                message_change_events: account::new_event_handle<MessageChangeEvent>(&account),\n            })\n        } else {\n            let old_message_holder = borrow_global_mut<MessageHolder>(account_addr);\n            let from_message = old_message_holder.message;\n            event::emit_event(&mut old_message_holder.message_change_events, MessageChangeEvent {\n                from_message,\n                to_message: copy message,\n            });\n            old_message_holder.message = message;\n        }\n    }\n\n    #[test(account = @0x1)]\n    public entry fun sender_can_set_message(account: signer) acquires MessageHolder {\n        let addr = signer::address_of(&account);\n        aptos_framework::account::create_account_for_test(addr);\n        set_message(account,  string::utf8(b\"Hello, Blockchain\"));\n\n        assert!(\n          get_message(addr) == string::utf8(b\"Hello, Blockchain\"),\n          ENO_MESSAGE\n        );\n    }\n}\n",  
    arweave_tx_id: "hgGXXTs5WL-fvGdajPHRiiviSlIj7D1_LUDOlHB7mFs", 
    origin_dataset_name: origin_dataset_name,
    tags: 
        %{
            uploader: "0x2df41622c0c1baabaa73b2c24360d205e23e803959ebbcb0e5b80462165893ed", 
            uploader_type: "aptos", 
            origin_dataset_name: "aptos-smart-contracts", 
            catalog: "move-example", 
            file_source: "https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/move-examples/hello_blockchain/sources/hello_blockchain.move"
        }
  })

VectorDatasetItem.create(%{
    unique_id: "f4455c5b-aa3d-43aa-9dbf-2ad2f586bbbf", 
    context: "module 0x42::prove {\n    fun plus1(x: u64): u64 {\n        x+1\n    }\n    spec plus1 {\n        ensures result == x+1;\n    }\n\n    fun abortsIf0(x: u64) {\n        if (x == 0) {\n            abort(0)\n        };\n    }\n    spec abortsIf0 {\n        aborts_if x == 0;\n    }\n}\n",  
    arweave_tx_id: "FWooNyRjn0E3G8DWymwcM6QLTXvIsj-WJos3P_GBOcA", 
    origin_dataset_name: origin_dataset_name,
    tags: 
        %{
            uploader: "0x2df41622c0c1baabaa73b2c24360d205e23e803959ebbcb0e5b80462165893ed", 
            uploader_type: "aptos", 
            origin_dataset_name: "aptos-smart-contracts", 
            catalog: "move-example", 
            file_source: "https://github.com/aptos-labs/aptos-core/blob/main/aptos-move/move-examples/hello_prover/sources/prove.move"
        }
  })