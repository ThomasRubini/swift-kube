import Foundation

struct Node {
    var id: Int
    var cpu: Int
    var ram: Int
    var pods: [Pod]
}

struct Pod {
    var id: Int
    var containers: [Container]
}

struct Container {
    var name: String
    var status: String
    var cpu: Int
    var ram: Int
}

func parseContainerStatus(line: String) -> Container {
    let containerDetails = line.replacingOccurrences(of: "Container: ", with: "").split(separator: "|")
    let containerName = containerDetails[0].split(separator: " ")[0]
    let containerStatus = containerDetails[1].split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
    let containerCpu = Int(containerDetails[2].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
    let containerRam = Int(containerDetails[3].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
    
    return Container(name: String(containerName), status: String(containerStatus), cpu: containerCpu, ram: containerRam)
}

// Récupération du statut du cluster
func parseClusterStatus(fileContent: String) -> [Node] {

    var nodes = [Node]()
    var currentNode: Node?
    var currentPod: Pod?

    for line in fileContent.split(separator: "\n") {
        let trimmedLine = line.trimmingCharacters(in: .whitespaces)

        // Check for node information
        if trimmedLine.hasPrefix("Node:") {
            let nodeId = Int(trimmedLine.split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!

            let node = Node(id: nodeId, cpu: 0, ram: 0, pods: [])
            currentNode = node
            nodes.append(node)
        }

        // Check for node resources
        else if trimmedLine.hasPrefix("Ressources:") {
            let resources = trimmedLine.replacingOccurrences(of: "Ressources: ", with: "").split(separator: "|")
            let cpu = Int(resources[0].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
            let ram = Int(resources[1].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!

            if var currentNode = currentNode {
                currentNode.cpu = cpu
                currentNode.ram = ram
            } else {
                print("`Resources:` line found without Node")
            }
        }

        // Check for pod information
        else if trimmedLine.hasPrefix("Pod:") {
            let podId = Int(trimmedLine.split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
            currentPod = Pod(id: podId, containers: [])
            currentNode!.pods.append(currentPod!)
        }

        // Check for container information
        else if trimmedLine.hasPrefix("Container:") {
            let container = parseContainerStatus(line: trimmedLine)
            if var currentPod = currentPod {
                currentPod.containers.append(container)
            } else {
                print("`Container:` line found without Pod")
            }
        }
    }
    return nodes
}

// Example usage
if let fileContent = try? String(contentsOfFile: "kube_status.txt", encoding: .utf8) {
    let res = parseClusterStatus(fileContent: fileContent)
    print(res)
}