import UIKit

// true 실내 운동, false 실외 운동
var exerciseListFlag:Bool = true

class ExerciseList: UIViewController {
    
    private let safeAreaView = UIView()
    
    struct Exercise: Equatable{
        let icon: UIImage
        var exerciseName: String
        var inOutFlag: Bool
        var favoritesFlag: Bool
        
        static func ==(lhs: Exercise, rhs: Exercise) -> Bool {
            // 속성들을 비교하여 같은지를 판단하는 로직
            return lhs.exerciseName == rhs.exerciseName
        }
    }
    
    lazy var exerciseList: [Exercise] = [
        // indoor
        Exercise(icon: UIImage(named: "cooldown")!, exerciseName: "스트레칭", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "pilates")!, exerciseName: "필라테스", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "yoga")!, exerciseName: "요가", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "mind")!, exerciseName: "명상", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "cardio")!, exerciseName: "유산소 운동", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "flexibility")!, exerciseName: "유연성 운동", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "strength")!, exerciseName: "근력 운동", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "jumprope")!, exerciseName: "줄넘기", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "indoorcycle")!, exerciseName: "실내 자전거", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "intervaltraining")!, exerciseName: "인터벌 트레이닝", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "crossTraining")!, exerciseName: "크로스 트레이닝", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "core")!, exerciseName: "코어 운동", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "elliptical")!, exerciseName: "일립티컬", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "dance")!, exerciseName: "댄스", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "bowling")!, exerciseName: "볼링", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "boxing")!, exerciseName: "권투", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "fencing")!, exerciseName: "펜싱", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "gymnastics")!, exerciseName: "체조", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "basketball")!, exerciseName: "농구", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "barre")!, exerciseName: "발레", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "handball")!, exerciseName: "핸드볼", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "walk")!, exerciseName: "실내 걷기", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "run")!, exerciseName: "실내 달리기", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "badminton")!, exerciseName: "실내 배드민턴", inOutFlag: true, favoritesFlag: false),
        Exercise(icon: UIImage(named: "tennis")!, exerciseName: "실내 테니스", inOutFlag: true, favoritesFlag: false),
        
        // outdoor
        Exercise(icon: UIImage(named: "walk")!, exerciseName: "실외 걷기", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "run")!, exerciseName: "실외 달리기", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "hiking")!, exerciseName: "등산", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "outdoorcycle")!, exerciseName: "실외 자전거", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "badminton")!, exerciseName: "실외 배드민턴", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "football")!, exerciseName: "축구", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "americanfootball")!, exerciseName: "미식축구", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "rugby")!, exerciseName: "럭비", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "baseball")!, exerciseName: "야구", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "golf")!, exerciseName: "골프", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "climbing")!, exerciseName: "클라이밍", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "skiing")!, exerciseName: "스키", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "equestrian")!, exerciseName: "승마", inOutFlag: false, favoritesFlag: false),
        Exercise(icon: UIImage(named: "tennis")!, exerciseName: "실외 테니스", inOutFlag: false, favoritesFlag: false),
    ]
    
    // exercise copy data
    var copyData = [Exercise]()
    // 실내, 실외 데이터
    var inOutdoorCopyData = [Exercise]()
    // indoor
    var indoorList = [Exercise]()
    // outdoor
    var outdoorList = [Exercise]()
    // 즐겨찾기
    var favoritesList = [Exercise]()
    // 즐겨찾기 여부를 알 수 있는 배열
    var favoritesCheckArray = [Bool]()
    
    // Navigation title Label
    let titleLabel: UILabel = {
        let label = UILabel()
        
        label.text = "LOOKHEART"
        label.font = UIFont.systemFont(ofSize: 25, weight: .heavy) // 크기, 굵음 정도 설정
        label.textColor = .black
        
        return label
    }()
    
    lazy var batteryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold) // 크기, 굵음 정도 설정
        
        NotificationCenter.default.addObserver(self, selector: #selector(dataReceived(_:)), name: Notification.Name("Battery"), object: nil)
        
        return label
    }()
    
    @objc func dataReceived(_ notification: Notification){
        if let text = notification.object as? String {
            batteryLabel.text = text
            
            let progressString = text.trimmingCharacters(in: ["%"])
            let progressFloat = Float(progressString)!
            let max = 100
            batProgress.setProgress(progressFloat/Float(max), animated: false)
        }
    }
    
    // Navigation battery prograss
    lazy var batProgress: UIProgressView = {
        let battery = UIProgressView()
        
        battery.progressViewStyle = .default
        battery.progressTintColor = UIColor.red
        battery.trackTintColor = UIColor.lightGray
        battery.layer.cornerRadius = 8
        battery.frame = CGRect(x: 0, y: 0, width: 50, height: 0)
        battery.clipsToBounds = true
        // height 높이 설정
        battery.transform = battery.transform.scaledBy(x: 1, y: 3)
        
        return battery
    }()
    
    
    let customView: UIView = {
        let customView = UIView()
        customView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        return customView
    }()
    
    /*-------------------- 버튼 View 설정 --------------------*/
    
    lazy var indoorExerciseButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("실내 운동", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.backgroundColor = .clear
        indoorUnderLine.isHidden = false
        
        button.addTarget(self, action: #selector(indoorExerciseButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc func indoorExerciseButtonEvent(_ sender: UIButton) {
        outdoorExerciseButton.setTitleColor(.lightGray, for: .normal)
        indoorExerciseButton.setTitleColor(.black, for: .normal)
        
        outdoorUnderLine.isHidden = true
        indoorUnderLine.isHidden = false
        
        indoorTableView.isHidden = false
        outdoorTableView.isHidden = true
        
        exerciseListFlag = true
    }
    
    lazy var outdoorExerciseButton: UIButton = {
        let button = UIButton()
        
        button.setTitle("실외 운동", for: .normal)
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.backgroundColor = .clear
        
        button.addTarget(self, action: #selector(outdoorExerciseButtonEvent(_:)), for: .touchUpInside)
        
        return button
    }()
    
    @objc func outdoorExerciseButtonEvent(_ sender: UIButton) {
        outdoorExerciseButton.setTitleColor(.black, for: .normal)
        indoorExerciseButton.setTitleColor(.lightGray, for: .normal)
        
        outdoorUnderLine.isHidden = false
        indoorUnderLine.isHidden = true
        
        indoorTableView.isHidden = true
        outdoorTableView.isHidden = false
        
        exerciseListFlag = false
    }
    
    lazy var indoorUnderLine: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
        return label
    }()
    
    lazy var outdoorUnderLine: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0)
        label.isHidden = true
        return label
    }()
    
    lazy var buttonUnderLine: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0)
        return label
    }()
    
    let buttonView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    /*-------------------- 운동 View --------------------*/
    
    var favoritesLabel: UIButton = {
        let label = UIButton()
        label.setTitle("Favorites", for: .normal)
        label.setTitleColor(UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0), for: .normal)
        label.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        label.backgroundColor = .white
        label.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: -10, right: 10)
        label.isEnabled = false
        
        return label
    }()
    
    
    let favoritesBackground: UITableView = {
        let view = UITableView()
        view.backgroundColor = .white
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0).cgColor
        view.layer.cornerRadius = 20
        return view
    }()
    
    lazy var myRecordButton: UIButton = {
       let button = UIButton()

       button.setTitle("운동기록", for: .normal)
//       button.setTitleColor(UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0), for: .normal)
        button.setTitleColor(.darkGray, for: .normal)
       button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)

//       button.layer.borderColor = UIColor(red: 83/255, green: 136/255, blue: 247/255, alpha: 1.0).cgColor
        button.layer.borderColor =  UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
       button.layer.borderWidth = 2
        button.layer.cornerRadius = 10

       button.addTarget(self, action: #selector(recordButtonEvent(_:)), for: .touchUpInside)

       return button
   }()

    @objc func recordButtonEvent(_ sender: UIButton) {
        let exerciseView = ExerciseRecordVC()
        self.navigationController?.pushViewController(exerciseView, animated: true)
    }
    
    // MARK: - work
    lazy var recentButton: UIButton = {
       let button = UIButton()

       button.setTitle("최근기록", for: .normal)
        
        button.setTitleColor(.darkGray, for: .normal)
       button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .heavy)

        button.layer.borderColor =  UIColor(red: 234/255, green: 235/255, blue: 237/255, alpha: 1.0).cgColor
       button.layer.borderWidth = 2
        button.layer.cornerRadius = 10

       button.addTarget(self, action: #selector(recentButtonEvent(_:)), for: .touchUpInside)

       return button
   }()
    
    @objc func recentButtonEvent(_ sender: UIButton) {
        let exerciseView = RecentRecordVC()
        self.navigationController?.pushViewController(exerciseView, animated: true)
    }
    
    let indoorTableView: UITableView = {
        let tableView = UITableView()
        return tableView
    }()
    
    let outdoorTableView: UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        return tableView
    }()
    
    let favoritesTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.layer.cornerRadius = 20
        return tableView
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // init
//        favoritesCheckArray = [Bool](repeating: false, count: exerciseList.count)
//        UserDefaults.standard.set(favoritesCheckArray, forKey: "FavArray")
        
        // 배열이 있는 경우
        if let favoritesCheckArrayCopy = UserDefaults.standard.array(forKey: "FavArray") as? [Bool] {
            favoritesCheckArray = favoritesCheckArrayCopy
        }
        // 배열이 없는 경우
        else
        {
            favoritesCheckArray = [Bool](repeating: false, count: exerciseList.count)
        }
        
        dataSort()
        setup()
        Constraints()
        
        // safeAreaView 설정
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                safeAreaView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                guide.bottomAnchor.constraint(equalToSystemSpacingBelow: safeAreaView.bottomAnchor, multiplier: 1.0)
            ])
        } else {
            let standardSpacing: CGFloat = 8.0
            NSLayoutConstraint.activate([
                safeAreaView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: standardSpacing),
                bottomLayoutGuide.topAnchor.constraint(equalTo: safeAreaView.bottomAnchor, constant: standardSpacing)
            ])
        }
        
        // Navigationbar Title 왼쪽 정렬
        self.navigationItem.leftBarButtonItem = UIBarButtonItem.init(customView: titleLabel)
        
        customView.addSubview(batProgress)
        customView.addSubview(batteryLabel)
        let barItem = UIBarButtonItem(customView: customView)
        navigationItem.rightBarButtonItem = barItem
        
        batteryLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            batProgress.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            batProgress.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: 0),
            
            batteryLabel.centerYAnchor.constraint(equalTo: batProgress.centerYAnchor),
            batteryLabel.trailingAnchor.constraint(equalTo: batProgress.leadingAnchor, constant: -10),
        ])
    }
    // 오름차순 정렬
    func arraySort(_ array: [Exercise]) -> [Exercise]{
        var sortArray = array
        sortArray.sort(){
            $0.exerciseName < $1.exerciseName
        }
        return sortArray
    }
    
    // MARK: - dataSort
    func dataSort(){
        
        copyData = exerciseList
        inOutdoorCopyData = exerciseList
        
        indoorList = []
        outdoorList = []

        // 즐겨 찾기 체크
        for i in 0 ..< copyData.count{
            copyData[i].favoritesFlag = favoritesCheckArray[i]
        }
        
        for i in 0 ..< copyData.count{
            if copyData[i].favoritesFlag == true{
                // 즐겨찾기 추가
                favoritesList.append(copyData[i])
                // 즐겨찾기 운동을 기존 배열에서 삭제하기 위한 변수
                let exerciseToFind = Exercise(icon: copyData[i].icon, exerciseName: copyData[i].exerciseName, inOutFlag: copyData[i].inOutFlag, favoritesFlag: copyData[i].favoritesFlag)
                // 즐겨찾기 운동을 기존 배열에서 삭제
                if let findIndex = inOutdoorCopyData.firstIndex(of: exerciseToFind){
                    inOutdoorCopyData.remove(at: findIndex)
                }
            }
        }
        
        for i in 0 ..< inOutdoorCopyData.count{
            if inOutdoorCopyData[i].inOutFlag == true {
                indoorList.append(inOutdoorCopyData[i])
            }
            else if inOutdoorCopyData[i].inOutFlag == false {
                outdoorList.append(inOutdoorCopyData[i])
            }
        }
        
        // 배열 정렬
        indoorList = arraySort(indoorList)
        outdoorList = arraySort(outdoorList)
        favoritesList = arraySort(favoritesList)
    }
    
    func setup(){
        view.backgroundColor = .white
        addViews()
    }
    func addViews(){
        
        view.addSubview(safeAreaView)
        
        view.addSubview(myRecordButton)
        view.addSubview(recentButton)
        
        view.addSubview(favoritesBackground)
        view.addSubview(favoritesLabel)
        
        view.addSubview(favoritesTableView)
        view.addSubview(indoorTableView)
        view.addSubview(outdoorTableView)
        
        
        indoorTableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.cellId)
        indoorTableView.delegate = self
        indoorTableView.dataSource = self
        indoorTableView.tag = 1
        
        outdoorTableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.cellId)
        outdoorTableView.delegate = self
        outdoorTableView.dataSource = self
        outdoorTableView.tag = 2
        
        favoritesTableView.register(CustomCell.self, forCellReuseIdentifier: CustomCell.cellId)
        favoritesTableView.delegate = self
        favoritesTableView.dataSource = self
        favoritesTableView.tag = 3
        
        view.addSubview(buttonView)
        buttonView.addSubview(indoorExerciseButton)
        buttonView.addSubview(outdoorExerciseButton)
        buttonView.addSubview(indoorUnderLine)
        buttonView.addSubview(outdoorUnderLine)
        buttonView.addSubview(buttonUnderLine)
        
        
        // battery progress를 navigationbar에 추가
        customView.addSubview(batProgress)
        customView.addSubview(batteryLabel)
        let barItem = UIBarButtonItem(customView: customView)
        navigationItem.rightBarButtonItem = barItem
        
        
    }
    func Constraints(){
        
        safeAreaView.translatesAutoresizingMaskIntoConstraints = false
        batteryLabel.translatesAutoresizingMaskIntoConstraints = false
        
        myRecordButton.translatesAutoresizingMaskIntoConstraints = false
        recentButton.translatesAutoresizingMaskIntoConstraints = false
        
        favoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        favoritesBackground.translatesAutoresizingMaskIntoConstraints = false
        
        // tableView
        favoritesTableView.translatesAutoresizingMaskIntoConstraints = false
        indoorTableView.translatesAutoresizingMaskIntoConstraints = false
        outdoorTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // buttonView
        buttonView.translatesAutoresizingMaskIntoConstraints = false
        indoorExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        outdoorExerciseButton.translatesAutoresizingMaskIntoConstraints = false
        indoorUnderLine.translatesAutoresizingMaskIntoConstraints = false
        outdoorUnderLine.translatesAutoresizingMaskIntoConstraints = false
        buttonUnderLine.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // safeAreaView
            safeAreaView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            safeAreaView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            batProgress.centerYAnchor.constraint(equalTo: customView.centerYAnchor),
            batProgress.trailingAnchor.constraint(equalTo: customView.trailingAnchor, constant: 0),
            batteryLabel.centerYAnchor.constraint(equalTo: batProgress.centerYAnchor),
            batteryLabel.trailingAnchor.constraint(equalTo: batProgress.leadingAnchor, constant: -10),
            
            myRecordButton.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 0),
            myRecordButton.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -20),
            myRecordButton.heightAnchor.constraint(equalToConstant: 40),
            myRecordButton.widthAnchor.constraint(equalToConstant: 70),
            
            recentButton.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 0),
            recentButton.trailingAnchor.constraint(equalTo: myRecordButton.leadingAnchor, constant: -10),
            recentButton.heightAnchor.constraint(equalToConstant: 40),
            recentButton.widthAnchor.constraint(equalToConstant: 70),
//            
//            favoritesBackground.topAnchor.constraint(equalTo: safeAreaView.topAnchor, constant: 10),
            favoritesBackground.topAnchor.constraint(equalTo: myRecordButton.bottomAnchor, constant: 10),
            favoritesBackground.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor, constant: 20),
            favoritesBackground.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor, constant: -20),
            favoritesBackground.heightAnchor.constraint(equalToConstant: 180),
            
            favoritesLabel.topAnchor.constraint(equalTo: favoritesBackground.topAnchor, constant: -10),
            favoritesLabel.leadingAnchor.constraint(equalTo: favoritesBackground.leadingAnchor, constant: 40),
            
            favoritesTableView.topAnchor.constraint(equalTo: favoritesBackground.topAnchor, constant: 10),
            favoritesTableView.leadingAnchor.constraint(equalTo: favoritesBackground.leadingAnchor, constant: 5),
            favoritesTableView.trailingAnchor.constraint(equalTo: favoritesBackground.trailingAnchor, constant: -10),
            favoritesTableView.bottomAnchor.constraint(equalTo: favoritesBackground.bottomAnchor, constant: -5),
            
            /*----------------------- buttonView -----------------------*/
            
            buttonView.topAnchor.constraint(equalTo: favoritesBackground.bottomAnchor, constant: 0),
            buttonView.leadingAnchor.constraint(equalTo: safeAreaView.leadingAnchor),
            buttonView.trailingAnchor.constraint(equalTo: safeAreaView.trailingAnchor),
            buttonView.heightAnchor.constraint(equalToConstant: 60),
            
            buttonUnderLine.bottomAnchor.constraint(equalTo: indoorUnderLine.bottomAnchor),
            buttonUnderLine.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor),
            buttonUnderLine.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor),
            buttonUnderLine.heightAnchor.constraint(equalToConstant: 1),
            
            indoorExerciseButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            indoorExerciseButton.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor, constant: -80),
            
            outdoorExerciseButton.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            outdoorExerciseButton.centerXAnchor.constraint(equalTo: buttonView.centerXAnchor, constant: 80),
            
            indoorUnderLine.topAnchor.constraint(equalTo: indoorExerciseButton.bottomAnchor, constant: 6),
            indoorUnderLine.leadingAnchor.constraint(equalTo: indoorExerciseButton.leadingAnchor, constant: -30),
            indoorUnderLine.trailingAnchor.constraint(equalTo: indoorExerciseButton.trailingAnchor, constant: 30),
            indoorUnderLine.heightAnchor.constraint(equalToConstant: 4),
            
            outdoorUnderLine.topAnchor.constraint(equalTo: outdoorExerciseButton.bottomAnchor, constant: 6),
            outdoorUnderLine.leadingAnchor.constraint(equalTo: outdoorExerciseButton.leadingAnchor, constant: -30),
            outdoorUnderLine.trailingAnchor.constraint(equalTo: outdoorExerciseButton.trailingAnchor, constant: 30),
            outdoorUnderLine.heightAnchor.constraint(equalToConstant: 4),
            
            /*----------------------- Exercise -----------------------*/
            
            indoorTableView.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 5),
            indoorTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            indoorTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            indoorTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            outdoorTableView.topAnchor.constraint(equalTo: buttonView.bottomAnchor, constant: 5),
            outdoorTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            outdoorTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            outdoorTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
}

// MARK: - TableView
extension ExerciseList:  UITableViewDataSource, UITableViewDelegate {
    
    // 각 섹션에 표시할 행의 갯수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView.tag == 1) {
            return indoorList.count
        }
        else if(tableView.tag == 2) {
            return outdoorList.count
        }
        else {
            return favoritesList.count
        }
    }
    
    // 특정 인덱스 Row의 Cell에 대한 정보를 넣어 Cell을 반환하는 메서드
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCell.cellId, for: indexPath) as! CustomCell
        // 실내 운동
        if(tableView.tag == 1){
            cell.flag = false
            cell.icon.image = indoorList[indexPath.row].icon
            cell.exerciseName.text = indoorList[indexPath.row].exerciseName
            cell.imgChange()
        }
        // 실외 운동
        else if(tableView.tag == 2){
            cell.flag = false
            cell.icon.image = outdoorList[indexPath.row].icon
            cell.exerciseName.text = outdoorList[indexPath.row].exerciseName
            cell.imgChange()
        }
        // 즐겨찾기
        else{
            cell.flag = true
            cell.icon.image = favoritesList[indexPath.row].icon
            cell.exerciseName.text = favoritesList[indexPath.row].exerciseName
            cell.imgChange()
        }
        
        // button touch event
        cell.favoritesCheck = { [self] in
            // 실내 운동
            if exerciseListFlag == true && tableView.tag == 1 {
                indoorList[indexPath.row].favoritesFlag = true
            
                let exerciseToFind = Exercise(icon: indoorList[indexPath.row].icon, exerciseName: indoorList[indexPath.row].exerciseName, inOutFlag: indoorList[indexPath.row].inOutFlag, favoritesFlag: indoorList[indexPath.row].favoritesFlag)
                
                if let index = exerciseList.firstIndex(of: exerciseToFind){
                    favoritesCheckArray[index] = true
                }
                else {
                    print("notFound")
                }
                
                UserDefaults.standard.set(favoritesCheckArray, forKey: "FavArray")
                
                favoritesList.append(indoorList[indexPath.row])
                indoorList.remove(at: indexPath.row)

                favoritesList = arraySort(favoritesList)
                
                favoritesTableView.reloadData()
                indoorTableView.reloadData()

            }
            // 실외 운동
            else if exerciseListFlag == false && tableView.tag == 2 {
                
                outdoorList[indexPath.row].favoritesFlag = true
                
                let exerciseToFind = Exercise(icon: outdoorList[indexPath.row].icon, exerciseName: outdoorList[indexPath.row].exerciseName, inOutFlag: outdoorList[indexPath.row].inOutFlag, favoritesFlag: outdoorList[indexPath.row].favoritesFlag)
                
                if let index = exerciseList.firstIndex(of: exerciseToFind){
                    favoritesCheckArray[index] = true
                }
                else {
                    print("notFound")
                }
                
                UserDefaults.standard.set(favoritesCheckArray, forKey: "FavArray")
                
                
                favoritesList.append(outdoorList[indexPath.row])
                outdoorList.remove(at: indexPath.row)

                favoritesList = arraySort(favoritesList)
                
                favoritesTableView.reloadData()
                outdoorTableView.reloadData()
            }
            // 즐겨찾기 메뉴 해제
            else {
                // 즐겨찾기 -> 실내 운동
                if favoritesList[indexPath.row].inOutFlag == true {
                    favoritesList[indexPath.row].favoritesFlag = false
                    
                    let exerciseToFind = Exercise(icon: favoritesList[indexPath.row].icon, exerciseName: favoritesList[indexPath.row].exerciseName, inOutFlag: favoritesList[indexPath.row].inOutFlag, favoritesFlag: favoritesList[indexPath.row].favoritesFlag)
                    
                    if let index = exerciseList.firstIndex(of: exerciseToFind){
                        favoritesCheckArray[index] = false
                    }
                    else {
                        print("notFound")
                    }
                    
                    UserDefaults.standard.set(favoritesCheckArray, forKey: "FavArray")
                    
                    indoorList.append(favoritesList[indexPath.row])
                    favoritesList.remove(at: indexPath.row)
                    
                    indoorList = arraySort(indoorList)
                    
                    indoorTableView.reloadData()
                }
                // 즐겨찾기 -> 실외 운동
                else if favoritesList[indexPath.row].inOutFlag == false {
                    favoritesList[indexPath.row].favoritesFlag = false
                    
                    let exerciseToFind = Exercise(icon: favoritesList[indexPath.row].icon, exerciseName: favoritesList[indexPath.row].exerciseName, inOutFlag: favoritesList[indexPath.row].inOutFlag, favoritesFlag: favoritesList[indexPath.row].favoritesFlag)
                    
                    if let index = exerciseList.firstIndex(of: exerciseToFind){
                        favoritesCheckArray[index] = false
                    }
                    else {
                        print("notFound")
                    }
                    
                    UserDefaults.standard.set(favoritesCheckArray, forKey: "FavArray")
                    
                    outdoorList.append(favoritesList[indexPath.row])
                    favoritesList.remove(at: indexPath.row)
                    
                    outdoorList = arraySort(outdoorList)
                    
                    outdoorTableView.reloadData()
                }
                
                favoritesTableView.reloadData()
            }
        }
        
        return cell
    }
    // 셀의 높이를 반환
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // 텍스트나 이미지 등의 요소에 따라 동적으로 높이 결정
        let cellHeight: CGFloat = 44.0 // 기본 높이 설정
        
        return cellHeight
    }
    
    // cell touch event
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print(indexPath.section)
//        print(indexPath.row)
//        print(indoorList[indexPath.row].exerciseName)
        var exerciseName = ""
        
        if tableView.tag == 1 {
            exerciseName = indoorList[indexPath.row].exerciseName
        }
        else if tableView.tag == 2{
            exerciseName = outdoorList[indexPath.row].exerciseName
        }
        else {
            exerciseName = favoritesList[indexPath.row].exerciseName
        }
        
        let alert = UIAlertController(title: exerciseName, message: "운동하기", preferredStyle: UIAlertController.Style.alert)
        let cancel = UIAlertAction(title: "취소", style: UIAlertAction.Style.cancel, handler: nil)
        let complite = UIAlertAction(title: "확인", style: UIAlertAction.Style.default){ [self]_ in
            let exerciseView = ExerciseVC()
            self.navigationController?.pushViewController(exerciseView, animated: true)
            UserDefaults.standard.set(exerciseName, forKey: "ExerciseName")
        }
        
        alert.addAction(complite)
        alert.addAction(cancel)
        
        self.present(alert, animated: false)
        
    }
}
