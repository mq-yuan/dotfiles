return {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    opts = {
        strategies = {
            chat = {
                adapter = "aihubmix",
                roles = {
                    user = "mq-yuan"
                },
                keymaps = {
                    send = {
                        modes = { n = "<C-s>", i = "<C-s>" },
                        opts = {},
                    },
                    close = {
                        modes = { n = "q" },
                        opts = {},
                    },
                    regenerate = {
                        modes = { n = "<C-r>" },
                        opts = {},
                    },
                    stop = {
                        modes = { n = "<C-c>" },
                        opts = {},
                    }
                },
            },
            inline = {
                adapter = {
                    name = "aihubmix",
                    model = "gemini-2.5-flash",
                }
            },
            cmd = {
                adapter = {
                    name = "aihubmix",
                    model = "gemini-2.5-flash",
                }
            }
        },
        adapters = {
            aihubmix = function ()
                return require("codecompanion.adapters").extend("openai_compatible", {
                    env = {
                        url = "https://aihubmix.com",
                        api_key = os.getenv("AIHUBMIX_API_KEY")
                    },
                    scheme = {
                        model = {
                            default = "gemini-2.5-flash"
                        }
                    }
                })
            end
        },
        prompt_library = {
            ["Generate a Commit Message"] = {
                strategy = "chat",
                description = "Generate a commit message",
                opts = {
                    index = 10,
                    is_default = true,
                    is_slash_cmd = true,
                    short_name = "commit",
                    auto_submit = true,
                },
                prompts = {
                    {
                        role = "user",
                        content = function()
                            return string.format(
                                [[
You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:
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
                        opts = {
                            contains_code = true,
                        },
                    },
                },
            },
            ["Generate Docs"] = {
                strategy = "inline",
                description = "Generate documentation for the selected code",
                opts = {
                    modes = { "v" },
                    placement = "above",
                    auto_submit = true,
                    user_prompt = false,
                    stop_context_insertion = true,
                },
                prompts = {
                    {
                        role = "system",
                        content = [[
You are an expert programmer specializing in writing clear and concise documentation. Your task is to generate a professional docstring or comment block for the given code snippet.
- First, identify the programming language of the code.
- Adhere to the standard documentation style for that language (e.g., Google Style for Python as in the user's example, JSDoc for JavaScript/TypeScript, Doxygen for C++, etc.).
- The documentation must describe the function's purpose, its arguments (Args), and what it returns or yields (Returns/Yields).
- CRITICAL RULE: You must only return the raw docstring or comment block itself. DO NOT include the original function, any surrounding markdown code blocks (like ```python), or any explanatory text.
                        ]],
                    },
                    {
                        role = "user",
                        content = function(context)
                            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                                return string.format(
                                    [[
[EXAMPLE START]
INPUT CODE (python):
```python
def my_function(param1: int, param2: str) -> bool:
    # A function that does something.
    if param1 > 0 and param2 == "start":
        return True
    return False
```
OUTPUT DOCSTRING:
"""Does something based on parameters.

Args:
param1 (int): The first parameter.
param2 (str): The second parameter.

Returns:
bool: True if conditions are met, otherwise False.
"""
[EXAMPLE END]

[TASK START]
INPUT CODE (%s):
```%s
%s
```
OUTPUT DOCSTRING:
]],
                                context.filetype,
                                context.filetype,
                                code
                            )
                        end,
                        opts = { contains_code = true },
                    },
                },
            },
            ["Translate Comments to English"] = {
                strategy = "inline",
                description = "Translate Chinese comments to English within a code block",
                opts = {
                    modes = { "v" },
                    -- Replace the entire selected block with the modified block
                    placement = "replace",
                    auto_submit = true,
                    user_prompt = false,
                    stop_context_insertion = true,
                },
                prompts = {
                    {
                        role = "system",
                        content = [[
You are an advanced, code-aware translation assistant. Your task is to process a block of code that contains a mix of source code, Chinese comments, and existing English comments.

Your one and only objective is to translate ALL Chinese comments into professional, idiomatic English, and leave everything else untouched.

Follow these rules strictly:
1.  You MUST NOT alter the source code in any way.
2.  You MUST NOT alter existing English comments.
3.  You MUST perfectly preserve the original indentation, spacing, and formatting.
4.  Your output MUST be the complete, reconstructed code block with only the Chinese comments replaced by their English translations.
                        ]],
                    },
                    {
                        role = "user",
                        content = function(context)
                            local code = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                            return string.format(
                                [[
[EXAMPLE START]
INPUT CODE BLOCK:
```python
# This is an existing English comment, do not touch it.
def calculate_score(data, weight):
    # 这是一个中文注释，计算最终分数。
    score = 0
    for item in data: # 根据权重累加
        score += item * weight
    return score
```
EXPECTED OUTPUT:
```python
# This is an existing English comment, do not touch it.
def calculate_score(data, weight):
    # This is a Chinese comment, calculating the final score.
    score = 0
    for item in data: # Accumulate according to weight
        score += item * weight
    return score
```
[EXAMPLE END]

[TASK START]
Please process the following code block according to the rules and example above.

INPUT CODE BLOCK:
```%s
%s
```
EXPECTED OUTPUT:
]],

                                context.filetype,
                                context.filetype,
                                code
                            )
                        end,
                        opts = { contains_code = true },
                    }
                },
            },
        }
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
    },
    specs = {
        {
            "AstroNvim/astrocore",
            opts = {
                mappings = {
                    n = {
                        ["<C-a>"] = { "<cmd>CodeCompanionActions<CR>", desc = "Open the action palette" },
                        ["<Leader>ag"] = { "<cmd>CodeCompanionChat Toggle<CR>", desc = "Toggle a chat buffer" },
                        ["<Leader>gm"] = { function ()
                            require("codecompanion").prompt("commit")
                        end, desc = "Generate AI Commit Message" },
                    },
                    v = {
                        ["<C-a>"] = { "<cmd>CodeCompanionActions<CR>", desc = "Open the action palette" },
                        ["<Leader>aa"] = { "<cmd>CodeCompanionChat Add<CR>", desc = "Add code to a chat buffer" },
                        ["<Leader>ce"] = { function ()
                            require("codecompanion").prompt("explain")
                        end, desc = "Explain visual selected code" },
                        ["<Leader>ad"] = { function()
                            require("codecompanion").prompt("Generate Docs")
                        end,  desc = "AI Generate Docs" },
                        ["<Leader>at"] = { function()
                            require("codecompanion").prompt("Translate Comments to English")
                        end,  desc = "AI Translate Comments to English" },

                    },
                },
            },
        },
    }
}
