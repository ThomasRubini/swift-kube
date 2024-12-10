import Foundation

// Récupération du statut du cluster
func parseClusterStatus(fileContent: String) -> Void {

    for line in fileContent.split(separator: "\n") {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)

        // Check for node information
        if trimmedLine.hasPrefix("Node:") {
            print("un noeud est détecté")
            let nodeId = Int(trimmedLine.split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
            print("nodeId: \(nodeId)")
        } 
        // Check for node resources
        else if trimmedLine.hasPrefix("Ressources:") {
            let resources = trimmedLine.replacingOccurrences(of: "Ressources: ", with: "").split(separator: "|")
            let cpu = Int(resources[0].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
            let ram = Int(resources[1].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
            print("Ressources de ce noeud : CPU: \(cpu), RAM: \(ram)")
        } 
        // Check for pod information
        else if trimmedLine.hasPrefix("Pod:") {
            print("Un pod est détecté")
            let podId = Int(trimmedLine.split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
            print("son id est : \(podId)")
        } 
        // Check for container information
        else if trimmedLine.hasPrefix("Container:") {
            let containerDetails = trimmedLine.replacingOccurrences(of: "Container: ", with: "").split(separator: "|")
            let containerName = containerDetails[0].split(separator: " ")[0]
            let containerStatus = containerDetails[1].split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
            let containerCpu = Int(containerDetails[2].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
            let containerRam = Int(containerDetails[3].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
            print("Container: \(containerName), Status: \(containerStatus), CPU: \(containerCpu), RAM: \(containerRam)")
        }
    }
}

// Example usage
if let fileContent = try? String(contentsOfFile: "/Users/vberry/Seafile/sCours/2425/DO3_Algo/Swift_codes/kubernetes_monitoring/kube_status.txt", encoding: .utf8) {
    parseClusterStatus(fileContent: fileContent)
}