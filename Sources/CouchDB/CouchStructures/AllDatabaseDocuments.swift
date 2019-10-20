/**
 * Copyright IBM Corporation 2018, 2019
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

/**
 A struct representing the JSON returned when querying a Database or View.
 If `includeDocuments` was true for the query, each row will have an additional "doc" field containing the JSON document.
 These documents can then be decoded to a given Swift type using `decodeDocuments(ofType:)`.
 
 CouchDB reference: [`All_Database_Documents`](http://docs.couchdb.org/en/stable/json-structure.html#all-database-documents)
 ### Usage Example: ###
 ```swift
 struct MyDocument: Document {
     let _id: String?
     var _rev: String?
     var value: String
 }
 database.retrieveAll(includeDocuments: true) { (allDocs, error) in
     if let allDocs = allDocs,
        let decodedDocs = allDocs.decodeDocuments(ofType: MyDocument)
     {
         for doc in decodedDocs {
            print("Retrieved MyDocument with value: \(doc.value)")
         }
     }
 }
 ```
 */
public struct AllDatabaseDocuments {
    init(total_rows: Int, offset: Int, rows: [[String: Any]], update_seq: String? = nil) {
        self.bookmark = nil
        self.total_rows = total_rows
        self.offset = offset
        self.rows = rows
        self.update_seq = update_seq
    }

    init(bookmark: String, rows: [[String: Any]], update_seq: String? = nil) {
        self.bookmark = bookmark
        self.total_rows = nil
        self.offset = nil
        self.rows = rows
        self.update_seq = update_seq
    }
    
    /// Allows you to page through the results.
    public let bookmark: String?
    
    /// Number of documents in the database/view.
    public let total_rows: Int?

    /// Offset where the document list started
    public let offset: Int?

    /// Current update sequence for the database.
    public let update_seq: String?
    
    /// The JSON response from a request to the view endpoint.
    /// Each element of the array contains an "id", "key" and "value" field.
    /// If "include_docs" was true, also contains the corresponding `Document` inside the "doc" field.
    /// http://docs.couchdb.org/en/stable/api/ddoc/views.html#api-ddoc-view
    public let rows: [[String: Any]]
    
    /// This function iterates through the `AllDatabaseDocuments` rows
    /// and returns the documents that could be successfully decoded as the given type.
    /// If the "includeDocuments" query parameter was false, this will return an empty array.
    public func decodeDocuments<T: Document>(ofType: T.Type) -> [T] {
        var documents = [T]()
        for row in rows {
            if let document = row["doc"],
                let data = try? JSONSerialization.data(withJSONObject: document),
                let decodedDocument = try? JSONDecoder().decode(T.self, from: data)
            {
                documents.append(decodedDocument)
            }
        }
        return documents
    }
}

