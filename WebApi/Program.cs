using Microsoft.AspNetCore.Http.HttpResults;
using WebApi.Services;
using WebApi.ValueObjects;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDistributedMemoryCache();

builder.Services.AddTransient<IExpensiveCalculation, ExpensiveCalculation>();
// builder.Services.AddTransient<IExpensiveCalculation, CachedExpensiveCalculation>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapGet("/calculate", async Task<Results<Ok<Money>, BadRequest>> (int a, Currency ac, int b, Currency bc, IExpensiveCalculation calculation) =>
{
    var result = await calculation.Run(new Money(a, ac), new Money(b, bc));

    return TypedResults.Ok(result);
})
.WithName("GetWeatherForecast");

app.Run();
