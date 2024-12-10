import Foundation

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
