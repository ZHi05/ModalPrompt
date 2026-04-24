import os
import argparse
import json
from tqdm import tqdm

from llava.eval.m4c_evaluator import EvalAIAnswerProcessor


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--test-file', type=str)
    parser.add_argument('--result-file', type=str)
    parser.add_argument('--output-dir', type=str)
    return parser.parse_args()


def eval_single(test_file, result_file):
    annotations = json.load(open(test_file))
    annotations_by_qid = {
        test['question_id']: test for test in annotations
        if isinstance(test, dict) and 'question_id' in test
    }
    results = [json.loads(line) for line in open(result_file)]
    answer_processor = EvalAIAnswerProcessor()

    total = len(results)
    right = 0
    false_answers = []
    for index in tqdm(range(total)):
        label = results[index]
        if annotations_by_qid:
            annotation = annotations_by_qid[label['question_id']]
            ground_truth = annotation['answer']
        else:
            ground_truth = annotations[index]['answer']

        text = answer_processor(ground_truth)
        pred = answer_processor(label['text'])
        if pred == text or text in pred or pred in text:
            right += 1
        else:
            label['ground_truth'] = ground_truth
            label['ground_truth_norm'] = text
            label['prediction_norm'] = pred
            false_answers.append(label)
        
    print('Samples: {}\nAccuracy: {:.2f}%\n'.format(total, 100. * right / total))

    if args.output_dir is not None:
        output_file = os.path.join(args.output_dir, 'Result.text')
        with open(output_file, 'w') as f:
            f.write('Samples: {}\nAccuracy: {:.2f}%\n'.format(total, 100. * right / total))
            json.dump(false_answers,f,indent=4)

if __name__ == "__main__":
    args = get_args()

    if args.result_file is not None:
        eval_single(args.test_file, args.result_file)
