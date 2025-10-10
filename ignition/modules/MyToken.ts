import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
// 빌드 모듈 가져오기 --> nomic...에서

// buildModule (모듈id, 모듈 정의 함수 입력받음)
export default buildModule("MyTokenDeploy", (m) => {
  const MyTokenC = m.contract("MyToken", ["MyToken", "MT", 18]);
  return { MyTokenC };
  // 오브젝트로 감싸서 리턴해줘야 한다?
});
