using System.Text.Json;
using Microsoft.Extensions.Caching.Distributed;
using WebApi.ValueObjects;

namespace WebApi.Services;

public sealed class ExpensiveCalculation : IExpensiveCalculation
{
    public async Task<Money> Run(Money a, Money b)
    {
        // await Task.Delay(3000);

        Money result = a + b;

        return result;
    }
}
