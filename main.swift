import Foundation

class Cluster : CustomStringConvertible {
    var nodes: [Node]

    init(nodes: [Node]) {
        self.nodes = nodes
    }

    var description: String {
        return "Cluster(nodes: \(nodes))"
    }

    func getContainers() -> [Container] {
        var containers = [Container]()
        for node in nodes {
            for pod in node.pods {
                containers.append(contentsOf: pod.containers)
            }
        }
        return containers
    }
}

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

    func usedResources() -> (Int, Int) {
        var usedCPU = 0
        var usedRAM = 0
        for pod in pods {
            for container in pod.containers {
                usedCPU += container.cpu
                usedRAM += container.ram
            }
        }
        return (usedCPU, usedRAM)
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
func parseClusterStatus(fileContent: String) -> Cluster {

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
    return Cluster(nodes: nodes)
}

func Q1(cluster: Cluster) {
    for node in cluster.nodes {
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

func Q2(cluster: Cluster) {
    for node in cluster.nodes {
        for pod in node.pods {
            var totalCpu = 0
            var totalRam = 0
            for container in pod.containers {
                totalCpu += container.cpu
                totalRam += container.ram
            }
            print("Le pod \(pod.id) sur le noeud \(node.id) utilise \(totalCpu) CPUs et \(totalRam) RAM.")
        }
    }
}

func Q3(cluster: Cluster) {
    var runningContainers = 0
    var stoppedContainers = 0
    var crashedContainers = 0

    for node in cluster.nodes {
        for pod in node.pods {
            for container in pod.containers {
                switch container.status {
                case .running:
                    runningContainers += 1
                case .stopped:
                    stoppedContainers += 1
                case .crashed:
                    crashedContainers += 1
                default:
                    break
                }
            }
        }
    }

    print("Résumé global du cluster:")
    print("Nombre total de conteneurs en cours d'exécution: \(runningContainers)")
    print("Nombre de conteneurs arrêtés: \(stoppedContainers)")
    print("Nombre de conteneurs crashés: \(crashedContainers)")
}

func Q4(cluster: Cluster) {
    for node in cluster.nodes {
        print("Le noeud \(node.id) a \(node.cpu) CPUs et \(node.ram) RAM disponibles.")
    }
}

struct RessourcesNeeded {
    var cpu: Int
    var ram: Int
}

func getRessourcesMaps() -> [String: RessourcesNeeded] {
    return [
        "postgres_db": RessourcesNeeded(cpu: 5, ram: 5),
        "redis_cache": RessourcesNeeded(cpu: 2, ram: 2),
        "kafka_broker": RessourcesNeeded(cpu: 50, ram: 50),
    ]
}

func Q5(cluster: Cluster) {
    for node in cluster.nodes {
        for pod in node.pods {
            for container in pod.containers {
                if container.status == .crashed {
                    // Query needed ressources for this container
                    let ressourcesMap = getRessourcesMaps()
                    let ressourcesNeededOpt = ressourcesMap[container.name]
                    if ressourcesNeededOpt == nil {
                        print("Le conteneur \(container.name) a crashé mais nous ne connaissons pas les ressources qu'il demande.")
                        continue
                    }
                    let ressourcesNeeded = ressourcesNeededOpt!

                    // Query node used ressources
                    var (usedCPU, usedRAM) = node.usedResources()
                    
                    // Calculate needed total node ressources to run the container
                    usedCPU -= container.cpu
                    usedRAM -= container.ram
                    usedCPU += ressourcesNeeded.cpu
                    usedRAM += ressourcesNeeded.ram

                    // Check if node has enough ressources
                    if usedCPU <= node.cpu && usedRAM <= node.ram {
                        print("Le conteneur \(container.name) a crashé mais le noeud a suffisamment de ressources pour le redémarrer.")
                        container.status = .running
                    } else {
                        print("Le conteneur \(container.name) a crashé et le noeud n'a pas suffisamment de ressources pour le redémarrer.")
                    }
                }
            }
        }
    }
}

func Q6(cluster: Cluster, wantedType: String) {
    let containers = cluster.getContainers().filter({ container in
        return container.name == wantedType
    })

    print("Nombre de conteneurs de type \(wantedType): \(containers.count)")
}

func Q7(cluster: Cluster, wantedType: String) {
    let containers = cluster.getContainers().filter({ container in
        return container.name == wantedType
    })

    var totalCpu = 0
    var totalRam = 0
    for container in containers {
        totalCpu += container.cpu
        totalRam += container.ram
    }

    print("Ressources totales utilisées par les conteneurs de type \(wantedType): \(totalCpu) CPUs et \(totalRam) RAM.")
}

func main() {
    let fileContentOpt = try? String(contentsOfFile: "kube_status.txt", encoding: .utf8)
    if fileContentOpt == nil {
        print("Error: could not read file")
        return
    }
    let fileContent = fileContentOpt!
    let cluster = parseClusterStatus(fileContent: fileContent)

    Q1(cluster: cluster)
    print("--------------------")
    Q2(cluster: cluster)
    print("--------------------")
    Q3(cluster: cluster)
    print("--------------------")
    Q4(cluster: cluster)
    print("--------------------")
    Q5(cluster: cluster)
    print("--------------------")
    Q6(cluster: cluster, wantedType: "postgres_db")
    print("--------------------")
    Q7(cluster: cluster, wantedType: "postgres_db")

}

main()
