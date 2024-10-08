var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();


app.MapGet("/", () =>
{
    var dotnetVersion = Environment.Version.ToString();

    return $"Hello world from dotnet\n.NET version: {dotnetVersion}";
});

app.Run();
