using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

namespace MyGallery.Pages;

public class IndexModel : PageModel
{
    private readonly IWebHostEnvironment _environment;
    internal List<FileModel> Files { get; set; } = [];
    private readonly ILogger<IndexModel> _logger;
    private const string _path = "Images";

    public IndexModel(IWebHostEnvironment environment, ILogger<IndexModel> logger)
    {
        _environment = environment;
        _logger = logger;
    }

    public void OnGet()
    {
        var filePaths = Directory.GetFiles(Path.Combine(_environment.WebRootPath, _path), "*.jpg");
        Files = filePaths.Select(x => new FileModel
            { FileName = Path.GetFileName(x), Url = _path + "/" + Path.GetFileName(x) }).ToList();
    }
}

internal sealed class FileModel
{
    public string FileName { get; set; } = default!;
    public string Url { get; set; } = default!;
}