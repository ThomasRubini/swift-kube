import Foundation

class Node : CustomStringConvertible {
    var id: Int
    var cpu: Int
    var ram: Int
    var pods: [Pod]

    init(id: Int, cpu: Int, ram: Int, pods: [Pod]) {
        self.id = id
        self.cpu = cpu
        self.ram = ram
        self.pods = pods
    }

    var description: String {
        return "Node(id: \(id), cpu: \(cpu), ram: \(ram), pods: \(pods))"
    }
    
}

class Pod : CustomStringConvertible {
    var id: Int
    var containers: [Container]

    init(id: Int, containers: [Container]) {
        self.id = id
        self.containers = containers
    }

    var description: String {
        return "Pod(id: \(id), containers: \(containers))"
    }
}

enum ContainerStatus: String, CustomStringConvertible {
    case running = "running"
    case stopped = "stopped"
    case crashed = "crashed"
    case unknown = "unknown"

    var description: String {
        return self.rawValue
    }
}

class Container : CustomStringConvertible {
    var name: String
    var status: ContainerStatus
    var cpu: Int
    var ram: Int

    init(name: String, status: ContainerStatus, cpu: Int, ram: Int) {
        self.name = name
        self.status = status
        self.cpu = cpu
        self.ram = ram
    }

    var description: String {
        return "Container(name: \(name), status: \(status), cpu: \(cpu), ram: \(ram))"
    }
}

func parseContainerStatus(line: String) -> Container {
    let containerDetails = line.replacingOccurrences(of: "Container: ", with: "").split(separator: "|")
    let containerName = containerDetails[0].split(separator: " ")[0]
    var containerStatus = containerDetails[1].split(separator: ":")[1].trimmingCharacters(in: .whitespaces)
    let containerCpu = Int(containerDetails[2].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
    let containerRam = Int(containerDetails[3].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!

    containerStatus = containerStatus.lowercased()

    let status = ContainerStatus.init(rawValue: containerStatus) ?? .unknown
    if status == .unknown {
        print("Warning: unknown container status: \(containerStatus)")
    }
    
    return Container(name: String(containerName), status: status, cpu: containerCpu, ram: containerRam)
}

func parsePodHeader(line: String) -> Pod {
    let podId = Int(line.split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
    return Pod(id: podId, containers: [])
}

func parseNodeResources(line: String, node: Node) {
    let resources = line.replacingOccurrences(of: "Ressources: ", with: "").split(separator: "|")
    node.cpu = Int(resources[0].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
    node.ram = Int(resources[1].split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
}

func parseNodeHeader(line: String) -> Node {
    let nodeId = Int(line.split(separator: ":")[1].trimmingCharacters(in: .whitespaces))!
    return Node(id: nodeId, cpu: 0, ram: 0, pods: [])
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
            let node = parseNodeHeader(line: trimmedLine)
            currentNode = node
            nodes.append(node)
        }

        // Check for node resources
        else if trimmedLine.hasPrefix("Ressources:") {

            if let currentNode = currentNode {
                parseNodeResources(line: trimmedLine, node: currentNode)
            } else {
                print("`Resources:` line found without Node")
            }
        }

        // Check for pod information
        else if trimmedLine.hasPrefix("Pod:") {
            let pod = parsePodHeader(line: trimmedLine)
            currentPod = pod
            currentNode!.pods.append(pod)
        }

        // Check for container information
        else if trimmedLine.hasPrefix("Container:") {
            let container = parseContainerStatus(line: trimmedLine)
            if let currentPod = currentPod {
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
    for node in res {
        for pod in node.pods {
            for container in pod.containers {
                if container.status == .running {
                    print("Le conteneur \(container.name) dans le pod \(pod.id) sur le noeud \(node.id) fonctionne normalement.")
                } else if container.status == .stopped {
                    print("Le conteneur \(container.name) dans le pod \(pod.id) sur le noeud \(node.id) est arrêté.")
                } else if container.status == .crashed {
                    print("Le conteneur \(container.name) dans le pod \(pod.id) sur le noeud \(node.id) a crashé.")
                }
            }
        }
    }
}