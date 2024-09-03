return {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop", "README" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
}
