using System.Text.Json;
using Microsoft.Extensions.Caching.Distributed;
using WebApi.ValueObjects;

namespace WebApi.Services;

public sealed class CachedExpensiveCalculation : IExpensiveCalculation
{
    private const string CacheKey = "calculation-key";

    private readonly IDistributedCache _cache;
    private readonly IExpensiveCalculation _calculation;

    public CachedExpensiveCalculation(IDistributedCache cache,
                                      [FromKeyedServices("calculation-service")] IExpensiveCalculation calculation)
    {
        _cache = cache;
        _calculation = calculation;
    }

    public async Task<Money> Run(Money a, Money b)
    {
        string? cached = await _cache.GetStringAsync(CacheKey);

        if (cached is not null)
        {
            Money? money = JsonSerializer.Deserialize<Money>(cached);

            if (money is not null)
                return money;
        }

        Money result = await _calculation.Run(a, b);

        await _cache.SetStringAsync(CacheKey, JsonSerializer.Serialize(result));

        return result;
    }
}
