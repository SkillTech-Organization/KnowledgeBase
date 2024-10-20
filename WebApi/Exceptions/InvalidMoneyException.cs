namespace WebApi.Exceptions;

public class InvalidMoneyException(string message) : Exception(message)
{
    public static Exception InvalidAmount() => new InvalidMoneyException("Cannot be lower than 0.");

    public static Exception CurrencyMissmatch() => new InvalidMoneyException("Currencies have to be the same.");
}
