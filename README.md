# FriendlyDecodableErrors

Adds an extension on `DecodingError` to translate it to a more human-friendly form.

Callable in two ways:

    do {
        let model = try JSONDecoder().decode(Model.self, from: jsonData)
    } catch let error as DecodingError {
        // Static method
        let readable = FriendlyDecodableError.from(error)
        
        // Extension on `DecodingError`
        let readable2 = error.asHumanReadable()
    }
