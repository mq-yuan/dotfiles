local prompts = {
  TestCode = [[Write some test cases for the following code, only return the test cases.
Give the code content directly, do not use code blocks or other tags to wrap it.
Absolutely adhere to grammatical rules.]],
  DocString = [[You are an AI programming assistant. You need to write a really good docstring that follows a best practice for the given language.

Your core tasks include:
- parameter and return types (if applicable).
- any errors that might be raised or returned, depending on the language.

You must:
- Place the generated docstring before the start of the code.
- Follow the format of examples carefully if the examples are provided.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.]],

  WordTranslate = [[You are a translation expert. Your task is to translate all the text provided by the user into Chinese.

NOTE:
- All the text input by the user is part of the content to be translated, and you should ONLY FOCUS ON TRANSLATING THE TEXT without performing any other tasks.
- RETURN ONLY THE TRANSLATED RESULT.]],

  CodeExplain = "Explain the following code, please only return the explanation, and answer in Chinese",

  CommitMsg = function()
    -- Source: https://andrewian.dev/blog/ai-git-commits
    return string.format(
      [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:
1. First line: conventional commit format (type: concise description) (remember to use semantic types like feat, fix, docs, style, refactor, perf, test, chore, etc.)
2. Optional bullet points if more context helps:
   - Keep the second line blank
   - Keep them short and direct
   - Focus on what changed
   - Always be terse
   - Don't overly explain
   - Drop any fluffy or formal language

Return ONLY the commit message - no introduction, no explanation, no quotes around it.

Examples:
feat: add user auth system

- Add JWT tokens for API auth
- Handle token refresh for long sessions

fix: resolve memory leak in worker pool

- Clean up idle connections
- Add timeout for stale workers

Simple change example:
fix: typo in README.md

Very important: Do not respond with any of the examples. Your message must be based off the diff that is about to be provided, with a little bit of styling informed by the recent commits you're about to see.

Based on this format, generate appropriate commit messages. Respond with message only. DO NOT format the message in Markdown code blocks, DO NOT use backticks:

```diff
%s
```
]],
      vim.fn.system("git diff --no-ext-diff --staged")
    )
  end,
}

return {
    "Kurama622/llm.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
    cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
    config = function ()
        local tools = require("llm.tools")
        require("llm").setup({
            enable_trace = false,

            -- set temperature and assistant
            temperature = 0.3,
            top_p = 0.7,
            prompt = "You are a helpful chinese assistant.",

            -- set models
            models = {
                {
                    name = "gemini-2.0-flash",
                    url = "https://aihubmix.com/v1/chat/completions",
                    model = "gemini-2.0-flash",
                    api_type = "openai",
                    fetch_key = function()
                        return vim.env.GEMINI_API_KEY
                    end,
                    max_tokens = 1048576
                },
                {
                    name = "grok-3",
                    fetch_key = function()
                        return vim.env.XAI_API_KEY
                    end,
                    url = "https://api.x.ai/v1/chat/completions",
                    model = "grok-3",
                    api_type = "openai",
                    max_tokens = 128000,
                },
                {
                    name = "gemini-2.5-flash",
                    url = "https://aihubmix.com/v1/chat/completions",
                    model = "gemini-2.5-flash-preview-04-17-nothink",
                    api_type = "openai",
                    fetch_key = function()
                        return vim.env.GEMINI_API_KEY
                    end,
                    max_tokens = 128000,
                },
                {
                    name = "gemini-2.5-flash-thinking",
                    url = "https://aihubmix.com/v1/chat/completions",
                    model = "gemini-2.5-flash-preview-04-17",
                    api_type = "openai",
                    fetch_key = function()
                        return vim.env.GEMINI_API_KEY
                    end,
                    max_tokens = 128000,
                },
                {
                    name = "gemini-2.5-pro",
                    url = "https://aihubmix.com/v1/chat/completions",
                    model = "gemini-2.5-pro-preview-03-25",
                    api_type = "openai",
                    fetch_key = function()
                        return vim.env.GEMINI_API_KEY
                    end,
                    max_tokens = 128000,
                },
                {
                    name = "deepseek-chat",
                    fetch_key = function()
                        return vim.env.DEEPSEEK_API_KEY
                    end,
                    url = "https://api.deepseek.com/chat/completions",
                    model = "deepseek-chat",
                    api_type = "openai",
                    max_tokens = 800000,
                },
                {
                    name = "deepseek-R1",
                    fetch_key = function()
                        return vim.env.DEEPSEEK_API_KEY
                    end,
                    url = "https://api.deepseek.com/chat/completions",
                    model = "deepseek-reasoner",
                    api_type = "openai",
                    max_tokens = 800000,
                },
                {
                    name = "deepseek-R1T",
                    url = "https://aihubmix.com/v1/chat/completions",
                    model = "tngtech/DeepSeek-R1T-Chimera",
                    api_type = "openai",
                    fetch_key = function()
                        return vim.env.GEMINI_API_KEY
                    end,
                    max_tokens = 128000,
                },
            },

            -- set ui
            spinner = {
                text = {
                    "󰧞󰧞",
                    "󰧞󰧞",
                    "󰧞󰧞",
                    "󰧞󰧞",
                },
                hl = "Title",
            },
            prefix = {
                -- 
                user = { text = "😃 ", hl = "Title" },
                assistant = { text = "  ", hl = "Added" },
            },
            display = {
                diff = {
                    layout = "vertical", -- vertical|horizontal split for default provider
                    opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
                    provider = "default", -- default|mini_diff
                },
            },
            -- history_path = "/tmp/llm-history",
            save_session = true,
            max_history = 15,
            max_history_name_length = 20,

            -- stylua: ignore
            -- popup window options
            popwin_opts = {
                relative = "cursor", enter = true,
                focusable = true, zindex = 50,
                position = { row = -7, col = 15, },
                size = { height = 15, width = "50%", },
                border = { style = "single",
                    text = { top = " Explain ", top_align = "center" },
                },
                win_options = {
                    winblend = 0,
                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                },
            },

            -- stylua: ignore
            keys = {
                -- The keyboard mapping for the input window.
                ["Input:Submit"]      = { mode = {"n", "i"}, key = "<C-s>" },
                ["Input:Cancel"]      = { mode = {"n", "i"}, key = "<C-c>" },
                ["Input:Resend"]      = { mode = {"n", "i"}, key = "<C-r>" },

                -- only works when "save_session = true"
                ["Input:HistoryNext"] = { mode = {"n", "i"}, key = "<C-j>" },
                ["Input:HistoryPrev"] = { mode = {"n", "i"}, key = "<C-k>" },
                ["Input:ModelsNext"] = { mode = {"n", "i"}, key = "<C-h>" },
                ["Input:ModelsPrev"] = { mode = {"n", "i"}, key = "<C-l>" },

                -- The keyboard mapping for the output window in "split" style.
                ["Output:Ask"]        = { mode = "n", key = "i" },
                ["Output:Cancel"]     = { mode = "n", key = "<C-c>" },
                ["Output:Resend"]     = { mode = "n", key = "<C-r>" },

                -- The keyboard mapping for the output and input windows in "float" style.
                ["Session:Close"]     = { mode = "n", key = {"<esc>", "q"} },

                -- Focus
                ["Focus:Input"]       = { mode = "n", key = {"i", "<C-w>"} },
                ["Focus:Output"]      = { mode = { "n", "i" }, key = "<C-w>" },
            },

            app_handler = {
                -- ====================================
                -- ============ Code ==================
                -- ====================================
                OptimizeCode = {
                    handler = tools.side_by_side_handler,
                    opts = {
                        left = {
                            focusable = false,
                        },
                    },
                },
                OptimCompare = {
                    handler = tools.action_handler,
                    opts = {
                        language = "Chinese",
                    },
                },
                TestCode = {
                    handler = tools.side_by_side_handler,
                    prompt = prompts.TestCode,
                    opts = {
                        right = {
                            title = " Test Cases ",
                        },
                    },
                },
                CodeExplain = {
                    handler = tools.flexi_handler,
                    prompt = prompts.CodeExplain,
                    opts = {
                        enter_flexible_window = true,
                    },
                },
                DocString = {
                    prompt = prompts.DocString,
                    handler = tools.action_handler,
                    opts = {
                        only_display_diff = true,
                        templates = {
                            lua = [[- For the Lua language, you should use the LDoc style.
- Start all comment lines with "---".]],
                            python = [[- For the python language, you should use the numpy style.]],
                        },
                    },
                },

                -- ====================================
                -- ============ Translate =============
                -- ====================================
                WordTranslate = {
                    handler = tools.flexi_handler,
                    prompt = prompts.WordTranslate,
                    opts = {
                        fetch_key = function()
                            return vim.env.OPENAI_API_KEY
                        end,
                        url = "https://aihubmix.com/v1/chat/completions",
                        model = "gemini-2.0-flash",
                        api_type = "openai",
                        exit_on_move = false,
                        enter_flexible_window = true,
                    },
                },
                Translate = {
                    handler = tools.qa_handler,
                    opts = {
                        fetch_key = function()
                            return vim.env.OPENAI_API_KEY
                        end,
                        url = "https://aihubmix.com/v1/chat/completions",
                        model = "gemini-2.0-flash",
                        api_type = "openai",

                        component_width = "60%",
                        component_height = "50%",
                        query = {
                            title = " 󰊿 Trans ",
                            hl = { link = "Define" },
                        },
                        input_box_opts = {
                            size = "15%",
                            win_options = {
                                winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                            },
                        },
                        preview_box_opts = {
                            size = "85%",
                            win_options = {
                                winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                            },
                        },
                    },
                },

                -- ====================================
                -- ============== Chat ================
                -- ====================================
                AttachToChat = {
                    handler = tools.attach_to_chat_handler,
                    opts = {
                        is_codeblock = true,
                        inline_assistant = true,
                        language = "Chinese",
                    },
                },

                -- ====================================
                -- ============== Git =================
                -- ====================================
                CommitMsg = {
                    handler = tools.flexi_handler,
                    prompt = prompts.CommitMsg,
                    opts = {
                        enter_flexible_window = true,
                        apply_visual_selection = false,
                        win_opts = {
                            relative = "editor",
                            position = "50%",
                            zindex = 100,
                        },
                        accept = {
                            mapping = {
                                mode = "n",
                                keys = "<cr>",
                            },
                            action = function()
                                local contents = vim.api.nvim_buf_get_lines(0, 0, -1, true)
                                vim.api.nvim_command(string.format('!git commit -m "%s"', table.concat(contents, '" -m "')))

                                -- just for lazygit
                                vim.schedule(function()
                                    vim.api.nvim_command("LazyGit")
                                end)
                            end,
                        },
                    },
                },

                -- ====================================
                -- ============ Completion ============
                -- ====================================
                Completion = {
                    handler = tools.completion_handler,
                    opts = {
                        fetch_key = function()
                            return vim.env.GEMINI_API_KEY
                        end,
                        url = "https://aihubmix.com/v1",
                        model = "gpt-4o-mini",
                        api_type = "openai",

                        n_completions = 1,
                        context_window = 16000,
                        max_tokens = 256,
                        keep_alive = -1,
                        filetypes = {
                            sh = false,
                            zsh = false,
                        },
                        timeout = 10,
                        default_filetype_enabled = false,
                        auto_trigger = true,
                        only_trigger_by_keywords = true,
                        -- style = "blink.cmp",
                        style = "virtual_text",
                        keymap = {
                            virtual_text = {
                                accept = {
                                    mode = "i",
                                    keys = "<C-c>",
                                },
                                next = {
                                    mode = "i",
                                    keys = "<tab>",
                                },
                                prev = {
                                    mode = "i",
                                    keys = "<S-tab>",
                                },
                                toggle = {
                                    mode = "n",
                                    keys = "<leader>cp",
                                },
                            },
                        },
                    },
                },
            }
        })
    end,
    specs = {
        {
            "AstroNvim/astrocore",
            opts = {
                mappings = {
                    n = {
                        ["<Leader>ag"] = { "<CMD>LLMSessionToggle<CR>", desc = "Toggle LLM.nvim session" },
                        ["<Leader>at"] = { "<CMD>LLMAppHandler Translate<CR>", desc = "Toggle LLM.nvim Translate session" },
                        ["<Leader>gm"] = { "<CMD>LLMAppHandler CommitMsg<CR>", desc = "Generate AI Commit Message by LLM.nvim" },
                    },
                    x = {
                        ["<Leader>tc"] = { "<CMD>LLMAppHandler TestCode<CR>", desc = "Generate test code based your selected code by LLM.nvim" },
                        ["<Leader>ts"] = { "<CMD>LLMAppHandler WordTranslate<CR>", desc = "Translate visual region by LLM.nvim" },
                        ["<Leader>ao"] = { "<CMD>LLMAppHandler OptimCompare<CR>", desc = "Optim the selected code by LLM.nvim" },
                    },
                    v = {
                        ["<Leader>ce"] = { "<CMD>LLMAppHandler CodeExplain<CR>", desc = "Explain visual selected code by LLM.nvim" },
                        ["<Leader>cd"] = { "<CMD>LLMAppHandler DocString<CR>", desc = "Generate AI Doc String by LLM.nvim" },
                        ["<Leader>aa"] = { "<CMD>LLMAppHandler AttachToChat<CR>", desc = "Ask selected Code in session by LLM.nvim" },
                    },
                },
            },
        },
        -- -- close completion
        -- {
        --     "Saghen/blink.cmp",
        --     opts = {
        --         completion = {
        --             trigger = {
        --                 prefetch_on_insert = false,
        --                 -- allow triggering by white space
        --                 show_on_blocked_trigger_characters = {},
        --             },
        --         },
        --
        --         keymap = {
        --             ["<C-y>"] = {
        --                 function(cmp)
        --                     cmp.show({ providers = { "llm" } })
        --                 end,
        --             },
        --         },
        --
        --         sources = {
        --             default = { "llm" },
        --             providers = {
        --                 llm = {
        --                     name = "llm",
        --                     module = "llm.common.completion.frontends.blink",
        --                     timeout_ms = 10000,
        --                     score_offset = 100,
        --                     async = true,
        --                 }
        --             }
        --         }
        --     }
        -- }
    }
}
