import Foundation

struct ParsedTask: Decodable {
    let title: String
    let dueDate: String?
    let humanReadableDueDate: String?
    let priority: String?
}

class AIService {
    static let shared = AIService()
    private init() {}
    
    private var apiKey: String? {
        Bundle.main.infoDictionary?["OpenAIAPIKey"] as? String
    }
    
    func parseTaskWithAI(input: String, completion: @escaping (ParsedTask?) -> Void) {
        guard let apiKey = apiKey else {
            completion(nil)
            return
        }
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        let prompt = """
        You are a helpful assistant that extracts structured task information from natural language. 
        For each input, return a JSON object with these fields:
        - title: the main task title
        - dueDate: the due date and time in ISO 8601 format (or null if not present)
        - humanReadableDueDate: the due date in a human-friendly format (or null if not present)
        - priority: one of high, medium, or low (or null if not present)
        
        Examples:
        Input: "Doctor appointment on July 10, 2024 at 2:30pm, high priority"
        Output: {\"title\":\"Doctor appointment\",\"dueDate\":\"2024-07-10T14:30:00\",\"humanReadableDueDate\":\"July 10, 2024 at 2:30pm\",\"priority\":\"high\"}
        
        Input: "Buy groceries tomorrow at 5pm, low priority"
        Output: {\"title\":\"Buy groceries\",\"dueDate\":\"2024-07-04T17:00:00\",\"humanReadableDueDate\":\"tomorrow at 5pm\",\"priority\":\"low\"}
        
        Input: "Finish homework"
        Output: {\"title\":\"Finish homework\",\"dueDate\":null,\"humanReadableDueDate\":null,\"priority\":null}
        
        Now extract the fields from this input:
        \n\n\(input)\n\nReturn only the JSON object, nothing else.
        """
        let body: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 256,
            "temperature": 0.0
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("AIService error:", error)
                completion(nil)
                return
            }
            guard let data = data else {
                print("AIService: No data received")
                completion(nil)
                return
            }
            // Log the raw response for debugging
            if let raw = String(data: data, encoding: .utf8) {
                print("AIService raw response:\n", raw)
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    // Try to decode the JSON object from the content
                    if let contentData = content.data(using: .utf8) {
                        let parsed = try? JSONDecoder().decode(ParsedTask.self, from: contentData)
                        completion(parsed)
                        return
                    }
                }
                print("AIService: Could not parse AI response")
                completion(nil)
            } catch {
                print("AIService JSON error:", error)
                completion(nil)
            }
        }
        task.resume()
    }
} 