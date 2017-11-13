//
//  WyhDataViewController.m
//  WyhTestRegionMonitor
//
//  Created by wyh on 2017/11/7.
//  Copyright © 2017年 wyh. All rights reserved.
//

#import "WyhDataViewController.h"
#import "WyhLocationManager.h"
#import "WyhDataTableViewCell.h"

@interface WyhDataViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation WyhDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"数据";
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(64.0f, 0, 0, 0));
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)reloadData {
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}

#pragma mark - tableView delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    WyhDataTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WyhDataTableViewCell" forIndexPath:indexPath];
    cell.selectionStyle = 0;
    NSDictionary *dataDic = self.dataSource[indexPath.row];
    [cell setDataDic:dataDic];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dataDic = self.dataSource[indexPath.row];
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:(UITableViewRowActionStyleDefault) title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        if ([WyhLocationManager removeUserLocationInfoFromTime:dataDic[@"time"]]){
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
        }
    }];
    action.backgroundColor = [UIColor redColor];
    return @[action];
}

-(UISwipeActionsConfiguration *)tableView:(UITableView *)tableView trailingSwipeActionsConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dataDic = self.dataSource[indexPath.row];
    if (@available(iOS 11.0, *)) {
        UIContextualAction *deleteAction = [UIContextualAction contextualActionWithStyle:UIContextualActionStyleNormal title:@"删除" handler:^(UIContextualAction * _Nonnull action, __kindof UIView * _Nonnull sourceView, void (^ _Nonnull completionHandler)(BOOL)) {
            if ([WyhLocationManager removeUserLocationInfoFromTime:dataDic[@"time"]]){
                wyh_async_safe_dispatch(^{
                    [self.tableView reloadData];
                });
            }
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        return [UISwipeActionsConfiguration configurationWithActions:@[deleteAction]];
    } else {
        // Fallback on earlier versions
        return nil;
    }
}

#pragma mark - lazy

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadData)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerNib:[UINib nibWithNibName:@"WyhDataTableViewCell" bundle:nil] forCellReuseIdentifier:@"WyhDataTableViewCell"];
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithArray:[WyhLocationManager getUserInfosFromUD]];
        //需要倒序
        [_dataSource sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSDictionary *dict1 = obj1;
            NSDictionary *dict2 = obj2;
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            
            [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
            
            NSDate *date1= [dateFormatter dateFromString:dict1[@"time"]];
            NSDate *date2= [dateFormatter dateFromString:dict2[@"time"]];
            
            if (date1 == [date1 earlierDate: date2]) { //不使用intValue比较无效
                return NSOrderedDescending;//降序
            }else if (date1 == [date1 laterDate: date2]) {
                return NSOrderedAscending;//升序
            }else{
                return NSOrderedSame;//相等
            }
        }];
    }
    return _dataSource;
}

@end
