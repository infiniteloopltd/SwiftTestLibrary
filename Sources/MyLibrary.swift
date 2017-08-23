import Foundation

public func hiThere() -> String {
  return "This is the Car Registration API"
}

extension URLSession {
    func synchronousDataTask(urlrequest: URLRequest) -> (Data?, URLResponse?, Error?) {
        var data: Data?
        var response: URLResponse?
        var error: Error?

        let semaphore = DispatchSemaphore(value: 0)

        let dataTask = self.dataTask(with: urlrequest) {
            data = $0
            response = $1
            error = $2

            semaphore.signal()
        }
        dataTask.resume()

        _ = semaphore.wait(timeout: .distantFuture)

        return (data, response, error)
    }
}

func australia_lookup(registrationNumber: String, state: String, username: String, password: String) -> ([String: Any])
{
    let url = URL(string: "http://www.regcheck.org.uk/api/json.aspx/CheckAustralia/" + registrationNumber + "/" + state)
    return lookup(url: url!, username: username, password: password )
}

func usa_lookup(registrationNumber: String, state: String, username: String, password: String) -> ([String: Any])
{
    let url = URL(string: "http://www.regcheck.org.uk/api/json.aspx/CheckUSA/" + registrationNumber + "/" + state)
    return lookup(url: url!, username: username, password: password )
}


func europe_lookup(endpoint: String, registrationNumber: String, username: String, password: String) -> ([String: Any])
{
    let url = URL(string: "http://www.regcheck.org.uk/api/json.aspx/" + endpoint + "/" + registrationNumber)
    return lookup(url: url!, username: username, password: password )
}

func lookup(url: URL, username: String, password: String) -> ([String: Any]) {
    let loginString = String(format: "%@:%@", username, password)
    let loginData = loginString.data(using: String.Encoding.utf8)!
    let base64LoginString = loginData.base64EncodedString()

    var request = URLRequest(url: url)
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

    request.httpMethod = "GET"
    let (data, _ , _) = URLSession.shared.synchronousDataTask(urlrequest: request)

    let json = try? JSONSerialization.jsonObject(with: data!, options: [])

    let dictionary = json as? [String: Any]

    return dictionary!

}
