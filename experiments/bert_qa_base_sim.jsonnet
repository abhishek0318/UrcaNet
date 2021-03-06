// Configuration for the a machine comprehension model based on:
//   Seo, Min Joon et al. “Bidirectional Attention Flow for Machine Comprehension.”
//   ArXiv/1611.01603 (2016)
{
  "dataset_reader": {
    "type": "bert_qa",
    "max_context_length": 6,
    "tokenizer": {
      "type": "word",
      "word_splitter": {
        "type": "spacy_modified",
        "never_split": ["[SEP]"], 
      }
    },
    "token_indexers": {
      "bert": {
        "type": "bert-pretrained-modified",
        "pretrained_model": "bert-base-uncased",
        "do_lowercase": true,
      },
    },
    "add_history": true,
    "add_scenario": true,
  },
  "train_data_path": "sharc1-official/json/sharc_train_split.json",
  "validation_data_path": "sharc1-official/json/sharc_val_split.json",
  "model": {
    "type": "bert_qa",
    "use_scenario_encoding": true,
    "loss_weights": {"span_loss": 1, "action_loss": 5},
    "sim_class_weights": [0, 1, 50, 50],
    "sim_pretraining": true,
    "text_field_embedder": {
      "type": "basic",
      "token_embedders": {
        "bert": {
          "type": "bert-pretrained-modified",
          "pretrained_model": "bert-base-uncased",
          "requires_grad": true,
          "top_layer_only": true
        },
      },
      "embedder_to_indexer_map": {
        "bert": ["bert", "bert-offsets", "bert-type-ids", "history_encoding", "turn_encoding", "scenario_encoding"]
      },
      "allow_unmatched_keys": true
    },
    "sim_text_field_embedder": {
      "type": "basic",
      "token_embedders": {
        "bert": {
          "type": "bert-pretrained-modified",
          "pretrained_model": "bert-base-uncased",
          "requires_grad": true,
          "top_layer_only": true
        },
      },
      "embedder_to_indexer_map": {
        "bert": ["bert", null, "bert-type-ids"]
      },
      "allow_unmatched_keys": true
    }
  },
  "iterator": {
    "type": "bucket",
    "sorting_keys": [["bert_input", "num_tokens"]],
    "batch_size": 16
  },

  "trainer": {
    "type": "modified_trainer",
    "minimal_save": true,
    "num_epochs": 50,
    "patience": 10,
    "validation_metric": "+sim_macro_f1",
    "cuda_device": 0,
    "optimizer": {
      "type": "bert_adam",
      "lr": 3e-6,
      "weight_decay": 1e-4,
      "parameter_groups": [
        [["bias", "LayerNorm.bias", "LayerNorm.weight"], {"weight_decay": 0}],
      ]
    }
  }
}
