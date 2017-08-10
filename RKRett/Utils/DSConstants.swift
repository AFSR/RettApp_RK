//
//  DSConstants.swift
//  RKRett
//
//  Created by Pietro Degrazia on 8/28/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//


///TESTE DO PIETRO COM GIT BRANCHING - Agora mandando isso do master pro offline

//MARK: - Global Variables
//MARK: Constants
struct Constants{
    static let PasswordUseTouchId = "kPasswordUseTouchId"
}

public let kBgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

public let kDSFirstRun = "DSFirsRun"
public let kDSFirstWatchRun = "DSFirstWatchRun"

public let kReviewStepIdentifier = "ReviewConsentIdentifier"
public let kVisualStepIdentifier = "VisualConsentStep"
public let kSharingStepIdentifier = "SharingConsentIdentifier"

public let kDSQuizPlist = "DSQuiz"
public let kQuizIntroductionStepIdentifier = "QuizIntroductionStep"

public let kDSElegibilityPlist = "DSElegibility"

public let kParseApplicationId = "9T1MqzJWJ5LFZCzCrmqgmo9Egt60jjHL5gIO2s23"
public let kParseClientKey = "XUCH19yUKrsm9r3GYAS80S5HfAapZHJrFy1JP1Wq"

public let kDSConsentPlist = "DSConsent"
public let kUserHasConsentedKey = "DSUserHasConsentedKey"

public let kDSTasksListFileName = "DSTasks"
public let kDSLearnMorePlist = "DSLearnMore"

public let kDSOpenPasswordMaxSize = 4
public let kDSPasswordKey = "DSPasswordKey"

public let kUploadingConsentMessage = NSLocalizedString("Uploading your consent...", comment: "message to display while uploading consent pdf file")
public let kSimpleErrorMessage = NSLocalizedString("Ops, an error occurred...", comment: "message to display error uploading file")
public let kSigningUpMessage = NSLocalizedString("Signing up...", comment: "message to display while signing up user")
public let kLoggingInMessage = NSLocalizedString("Signing in...", comment: "message to display while signing user in")
public let kWatchQueryMessage = NSLocalizedString("Retriving data from Watch", comment: "message to display while quering data from watch")


public let kSundayIdentifier = 1

public let kTextAnswerMaxLength = 1000

public let kWatchRequestTimeout = 30

public let kDateDidEnterBackgroundKey = "kDateDidEnterBackgroundKey"

//MARK: Override operators
func == <T:Equatable> (tuple1:(T,T), tuple2:(T,T)) -> Bool{
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}

//MARK: Session MessageTypes
enum DSActionType: String{
    case Record = "record"
    case Query = "query"
    
    var description: String {
        return self.rawValue
    }
}

//MARK: Sesison MessageTypes
enum DSReviewType: String{
    
    case Like = "likes"
    case Dislike = "dislikes"
    
    var description: String {
        return self.rawValue
    }
}

//MARK: ActionItems should be included in the action Dictionary
enum DSActionItem: String{
    case ActionType = "actionType"
    //Duration is used when peforming a Record ActionType
    case Duration = "duration"
    
    //Frequency, FromDate, ToDate are used when performing a Query ActionType
    case Frequency = "frequency"
    case FromDate = "fromDate"
    case ToDate = "toDate"
    
    var description: String {
        return self.rawValue
    }
}

//MARK: Storyboard Enum
enum StoryboardName: String, CustomStringConvertible {
    case Main = "Main"
    case Consent = "Onboarding"
    case Password = "Password"
    
    var description: String {
        return self.rawValue
    }
}

//MARK: UserDefaults Update Enum
enum LastUpdated: String, CustomStringConvertible {
    case Key = "LastUpdated"
    case DayOfTheWeek = "DayOfTheWeek"
    case Month = "Month"
    
    var description: String {
        return self.rawValue
    }
}

//MARK: Task Types Enum
enum DSTaskTypes : String{
    case Number = "NSNumber"
    case Text = "String"
    case Query = "Query"
    case Introduction = "Introduction"
    case ImageChoice = "ImageChoice"
    case TextChoice = "TextChoice"
    case TimeOfDay = "TimeOfDay"
    case Task = "Task"
    
    var description: String {
        return self.rawValue
    }
}

//MARK: User Types Enum
enum UserType:String{
    case MD = "MD", Parent = "Parent", Patient = "Patient"
    
    var description: String {
        return self.rawValue
    }
}

//MARK: TabBarIndexes
enum TabBarItemIndexes:Int{
    case Tasks = 0, Dashboard = 1, LearnMore = 2, Profile = 3
    
    var description:Int{
        return self.rawValue
    }
}



//MARK: Sportlight search actions
enum SpotlightSearchActions:String{
    case Tasks = "Tasks", Dashboard = "Dashboard", LearnMore = "LearnMore", SendEmail = "SendEmail"
}

//MARK: Frequency Type
enum Frequency: String{
    enum Daily: String, CustomStringConvertible{
        case Key = "daily"
        var description:String{
            return self.rawValue
        }
    }
    enum Weekly: String, CustomStringConvertible{
        case Key = "weekly"
        var description:String{
            return self.rawValue
        }
    }
    enum Monthly: String, CustomStringConvertible{
        case Key = "monthly"
        var description:String{
            return self.rawValue
        }
    }
    case OnDemand = "onDemand"
    
    var description:String{
        return self.rawValue
    }
}

enum SectionTypePlistKey : String {
    case Overview = "Overview"
    case DataGathering = "DataGathering"
    case Privacy = "Privacy"
    case DataUse = "DataUse"
    case TimeCommitment = "TimeCommitment"
    case StudySurvey = "StudySurvey"
    case StudyTasks = "StudyTasks"
    case Withdrawing = "Withdrawing"
    case Custom = "Custom"
    case OnlyInDocument = "OnlyInDocument"
}


//MARK: Plist Structs

public struct PlistFile {
    
    //MARK: - Consent
    enum Consent:String, CustomStringConvertible{
        enum Section:String, CustomStringConvertible{
            case Title = "title"
            case Type = "type"
            case Animation = "animation"
            case Image = "image"
            case Summary = "summary"
            case Content = "content"
            case ButtonTitle = "buttonTitle"
            
            var description:String{
                return self.rawValue
            }
        }
        
        case VisualStep = "VisualStep"
        case Title = "title"
        case Extension = "extension"
        
        var description:String{
            return self.rawValue
        }
    }
    
    //MARK: - LearnMore
    enum Learn{
        enum Section:String, CustomStringConvertible{
            case Key = "sections"
            case Title = "sectionTitle"
            case Text = "sectionText"
            
            var description:String{
                return self.rawValue
            }
        }
    }
    
    //MARK: - Quiz
    enum Quiz{
        enum Question:String, CustomStringConvertible{
            case Key = "question"
            case Type = "type"
            case Title = "title"
            case Identifier = "identifier"
            case ExpectedAnswer = "expectedAnswer"
            
            var description:String{
                return self.rawValue
            }
        }
        
        enum Instruction:String, CustomStringConvertible{
            case Key = "instruction"
            case DetailText = "detailText"
            
            var description:String{
                return self.rawValue
            }
        }
    }
    
    //MARK: - Task
    enum Task:String, CustomStringConvertible{
        
        case TaskID = "taskId"
        case FrequencyType = "frequencyType"
        case FrequencyNumber = "frequencyNumber"
        case Name = "name"
        
        var description:String{
            return self.rawValue
        }
        
        case Type = "type"
        
        enum Question:String,CustomStringConvertible{
            case Key = "questions"
            case AnswerUnit = "answerUnit"
            case AnswerType = "answerType"
            case Prompt = "prompt"
            case QuestionID = "questionId"
            case Optional = "optional"
            
            enum Dashboard:String, CustomStringConvertible{
                case Key = "dashboard"
                case GraphType = "graphType"
                case YAxisColName = "yAxisColName"
                case TimeUnit = "timeUnit"
                case XScale = "xScale"
                case YScale = "yScale"
                case Title = "title"
                case Subtitle = "subtitle"
                enum Color:String, CustomStringConvertible{
                    case Key = "color"
                    case Red = "red"
                    case Green = "green"
                    case blue = "blue"
                    
                    var description:String{
                        return self.rawValue
                    }
                }
                
                
                var description:String{
                    return self.rawValue
                }
            }
            
            enum AnswerRange:String, CustomStringConvertible{
                case Key = "answerRange"
                case Minimum = "minimum"
                case Maximum = "maximum"
                
                var description:String{
                    return self.rawValue
                }
            }
            
            enum ImageChoice:String, CustomStringConvertible{
                case Key = "imageChoice"
                case SelectedImage = "selectedImage"
                case NormalImage = "normalImage"
                case Text = "text"
                case Value = "value"
                
                var description:String{
                    return self.rawValue
                }
            }
            
            enum TextChoice:String, CustomStringConvertible{
                case Key = "textChoice"
                case DetailText = "detailText"
                case Text = "text"
                case Value = "value"
                
                var description:String{
                    return self.rawValue
                }
            }
            
            var description:String{
                return self.rawValue
            }
        }
    }
}