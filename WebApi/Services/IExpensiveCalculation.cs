using WebApi.ValueObjects;

namespace WebApi.Services;

public interface IExpensiveCalculation
{
    Task<Money> Run(Money a, Money b);
}
