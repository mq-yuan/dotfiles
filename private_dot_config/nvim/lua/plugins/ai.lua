if true then return {} end
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
                            local branch_name = vim.fn.trim(vim.fn.system("git rev-parse --abbrev-ref HEAD"))
                            local changed_files = vim.fn.trim(vim.fn.system("git diff --name-only --staged"))
                            local staged_diff = vim.fn.system("git diff --no-ext-diff --staged")
                            local template = [[
You are an expert at writing Conventional Commits. Your task is to generate a concise and accurate commit message by analyzing the provided context.
**Analyze the following information:**
1.  **Branch Name:** This often contains the primary goal or feature name.
    `%s`
2.  **Changed Files:** This provides an overview of the components affected.
```files
%s
```
3.  **Staged Diff:** These are the specific code changes. Pay attention to the actual additions and deletions, not just the surrounding context lines.
```diff
%s
```
**Your instructions:**

1.  **Infer Intent:** First, use the **Branch Name** and **Changed Files** to understand the high-level purpose (the WHAT and WHY) of this commit.
2.  **Analyze Details:** Next, examine the **Staged Diff** to understand the implementation details (the HOW).
3.  **Generate Message:** Based on your analysis, generate the commit message following these strict rules:
    - **Line 1:** Use the Conventional Commit format (`type(scope): concise description`). Use semantic types like `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`. The scope is optional.
    - **Body (Optional):**
        - Leave the second line blank.
        - Use bullet points (`-`) for further explanation if needed.
        - Focus on what changed and why. Keep it brief and direct.

**Output Rules:**
- Return ONLY the raw commit message.
- No introductory phrases, no explanations, no yapping.
- DO NOT wrap the message in quotes or Markdown code blocks.

**Example Output 1 (Feature):**
feat(auth): implement password reset endpoint

- Add a new route `/api/auth/reset-password`.
- Implement token generation and email service for password reset.

**Example Output 2 (Simple Fix):**
fix: correct typo in page title

Now, based on the provided branch name, file list, and diff, generate the commit message.

]]
                            return string.format(template, branch_name, changed_files, staged_diff)
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
                    short_name = "docs",
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
                    short_name = "translate_comments_to_english",
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
            ["Translate to Chinese"] = {
                -- Use the 'chat' strategy to display the result without modifying the code
                strategy = "chat",
                description = "Translate selected text to Chinese in a chat window",
                opts = {
                    modes = { "v" },
                    auto_submit = true,
                    user_prompt = false,
                    stop_context_insertion = true,
                    short_name = "translate_to_chinese",
                },
                prompts = {
                    {
                        role = "system",
                        content = [[
You are a professional translator specializing in technical and programming-related content. Your task is to accurately translate the user-provided English text into simplified Chinese.

Follow these critical rules:
1.  You MUST preserve specific English proper nouns, acronyms, technical terms, and code-related identifiers in their original English form.
2.  For example, terms like 'Neovim', 'Python', 'CUDA', '3dgs', 'BERT', 'Transformer', variable names like `my_var`, and function names like `calculate_score()` should NOT be translated.
3.  Translate the surrounding explanatory text accurately and fluently into Chinese.
4.  Your final output should ONLY be the translated Chinese text, without any extra explanations or formatting.
                        ]],
                    },
                    {
                        role = "user",
                        content = function(context)
                            local text = require("codecompanion.helpers.actions").get_code(context.start_line, context.end_line)
                            return string.format(
                                [[Please translate the following text to Chinese, keeping in mind the rules about preserving technical terms:\n\n%s]],
                                text
                            )
                        end,
                        -- Although it might be plain text, treating it as containing code helps with formatting preservation.
                        opts = { contains_code = true },
                    },
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
                            require("codecompanion").prompt("docs")
                        end,  desc = "AI Generate Docs" },
                        ["<Leader>at"] = { function()
                            require("codecompanion").prompt("translate_comments_to_english")
                        end,  desc = "AI Translate Comments to English" },
                        ["<Leader>aT"] = { function()
                            require("codecompanion").prompt("translate_to_chinese")
                        end,  desc = "AI Translate to Chinese (Chat)" },

                    },
                },
            },
        },
    }
}
