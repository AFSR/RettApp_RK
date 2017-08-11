//
//  DSTaskCreator
//  RKRett
//
//  Created by Henrique Valcanaia on 8/20/15.
//  Copyright (c) 2015 DarkShine. All rights reserved.
//
//

import ResearchKit

public var DSTaskCreator:((NSDictionary) -> (ORKOrderedTask)) = { dictionary in
    
    var steps = [ORKStep]()
    if let questions = dictionary.object(forKey: "questions") as? NSArray{
        for question in questions{
            if let dicQuestion = question as? NSDictionary{
                let step = DSStepCreator.createQuestionStepUsingDictionary(dicQuestion)
                steps += [step]
            }else{
                print("Erro ao converter a question em NSDictionary")
            }
        }
    }
    
    let identifier = dictionary.object(forKey: "taskId") as! String
    
    return ORKOrderedTask(identifier: identifier, steps: steps)
}
