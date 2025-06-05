import common from '@ohos.app.ability.common';
import abilityAccessCtrl, { Permissions } from '@ohos.abilityAccessCtrl';
import { bundleManager, Context } from '@kit.AbilityKit';

export class PermissionRequestUtil {
  static getAccessTokenId(): number {
    let tokenId: number = 0;
    try {
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION);
      let appInfo: bundleManager.ApplicationInfo = bundleInfo.appInfo;
      tokenId = appInfo.accessTokenId;
    } catch (err) {
      console.error(`getBundleInfoForSelf failed, code is ${err.code}, message is ${err.message}`);
    }
    return tokenId
  }

  /**
   * 申请权限
   * @param context
   * @param permissionArray
   * @param listener
   */
  static requestPermission(context: Context, permissionArray: Array<Permissions>,
    listener?: (isGrant: boolean) => void) {
    let atManager = abilityAccessCtrl.createAtManager()
    try {
      atManager.requestPermissionsFromUser(context, permissionArray).then((data) => {
        let isAllGrant: boolean = true
        if (data && data.authResults && listener) {
          for (let i = 0; i < data.authResults.length; i++) {
            if (data.authResults[i] != abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED) {
              isAllGrant = false
              break
            }
          }
        }
        if (listener) {
          listener(isAllGrant)
        }
      })
    } catch (err) {
      if (listener) {
        listener(false)
      }
    }
  }

  /**
   * 检查权限申请
   * @param permissions
   * @returns
   */
  static checkAccessPermission(permissions: Array<Permissions>): Array<abilityAccessCtrl.GrantStatus> {
    let grantStatusArr: Array<abilityAccessCtrl.GrantStatus> = []
    try {
      let atManager = abilityAccessCtrl.createAtManager()
      let tokenId = PermissionRequestUtil.getAccessTokenId()
      permissions.forEach((permission: Permissions) => {
        grantStatusArr.push(atManager.checkAccessTokenSync(tokenId, permission))
      })
    } catch (err) {
      console.error(`checkAccessToken failed, code is ${err.code}, message is ${err.message}`);
    }
    return grantStatusArr
  }
}